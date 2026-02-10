defmodule NewsAgent.Chat.LLM.Gemini do
  @moduledoc false

  @behaviour NewsAgent.Chat.LLM.Provider

  alias NewsAgent.Gemini.Client
  require Logger

  @model "gemini-2.0-flash-lite"

  @impl true
  def generate(prompt, opts) when is_binary(prompt) do
    _ = System.fetch_env!("GEMINI_API_KEY")

    llm_opts = Keyword.get(opts, :llm_options, [])
    options = Keyword.merge([model: @model, max_output_tokens: 300, temperature: 0.3], llm_opts)
    request_id = NewsAgent.Gemini.build_request_id()
    system_instruction = Keyword.get(opts, :system_instruction)
    tools = NewsAgent.Gemini.grounding_tools(opts, true)
    payload = build_payload(prompt, options, tools, system_instruction)

    generate_with_retry(payload, options, retry_config(opts), request_id)
  end

  defp generate_with_retry(payload, options, config, request_id) do
    do_generate_with_retry(
      payload,
      options,
      config.retries,
      config.backoff_ms,
      config.timeout_ms,
      request_id,
      1
    )
  end

  defp do_generate_with_retry(
         payload,
         options,
         retries,
         backoff_ms,
         timeout_ms,
         request_id,
         attempt
       ) do
    Logger.debug(fn ->
      "Chat LLM attempt=#{attempt} timeout_ms=#{timeout_ms}"
    end)

    case generate_once(payload, options, timeout_ms, request_id, attempt) do
      {:ok, text, _duration_ms} ->
        {:ok, text}

      {:error, reason, duration_ms} ->
        metadata = %{
          request_id: request_id,
          model: options[:model],
          attempt: attempt,
          timeout_ms: timeout_ms,
          duration_ms: duration_ms
        }

        if NewsAgent.Gemini.retryable?(reason) and attempt <= retries do
          NewsAgent.Gemini.log_retry(:chat_llm, metadata, reason)
          Process.sleep(NewsAgent.Gemini.retry_backoff_ms(reason, backoff_ms))

          do_generate_with_retry(
            payload,
            options,
            retries,
            backoff_ms,
            timeout_ms,
            request_id,
            attempt + 1
          )
        else
          NewsAgent.Gemini.log_failure(:chat_llm, metadata, reason)

          {:error, reason}
        end
    end
  end

  defp generate_once(payload, options, timeout_ms, request_id, attempt) do
    start = System.monotonic_time()
    client_opts = [model: options[:model], timeout_ms: timeout_ms]
    task = Task.async(fn -> Client.generate(payload, client_opts) end)

    result =
      case Task.yield(task, timeout_ms) || Task.shutdown(task) do
        {:ok, value} ->
          value

        nil ->
          duration_ms = duration_ms(start)

          metadata = %{
            request_id: request_id,
            model: options[:model],
            attempt: attempt,
            timeout_ms: timeout_ms,
            duration_ms: duration_ms
          }

          if dev_env?() do
            NewsAgent.Gemini.log_failure(:chat_llm, metadata, :timeout)
            raise "LLM timeout. Increase NEWS_AGENT_CHAT_LLM_TIMEOUT_MS"
          end

          {:error, :timeout, duration_ms}
      end

    case result do
      {:ok, response} ->
        with {:ok, text} <- Client.extract_text(response) do
          text = String.trim(to_string(text))

          if text == "" do
            {:error, :empty_response, duration_ms(start)}
          else
            log_success(start, text)
            {:ok, text, duration_ms(start)}
          end
        else
          {:error, reason} ->
            {:error, reason, duration_ms(start)}

          _ ->
            {:error, :empty_response, duration_ms(start)}
        end

      {:error, reason} ->
        {:error, reason, duration_ms(start)}

      {:error, reason, duration_ms} ->
        {:error, reason, duration_ms}
    end
  end

  defp retry_config(opts) do
    %{
      retries: env_integer("NEWS_AGENT_CHAT_LLM_RETRIES", Keyword.get(opts, :llm_retries, 1)),
      backoff_ms:
        env_integer("NEWS_AGENT_CHAT_LLM_BACKOFF_MS", Keyword.get(opts, :llm_backoff_ms, 500)),
      timeout_ms:
        env_integer("NEWS_AGENT_CHAT_LLM_TIMEOUT_MS", Keyword.get(opts, :llm_timeout_ms, 4_000))
    }
  end

  defp env_integer(key, default) do
    case System.get_env(key) do
      value when is_binary(value) ->
        case Integer.parse(value) do
          {parsed, _} when parsed > 0 -> parsed
          _ -> default
        end

      _ ->
        default
    end
  end

  defp dev_env? do
    case Code.ensure_loaded?(Mix) do
      true -> Mix.env() == :dev
      false -> System.get_env("NEWS_AGENT_ENV") == "dev"
    end
  end

  defp log_success(start, text) do
    duration_ms = duration_ms(start)

    Logger.debug(fn ->
      "Chat LLM success duration_ms=#{duration_ms} chars=#{String.length(text)}"
    end)
  end

  defp duration_ms(start) do
    System.monotonic_time()
    |> Kernel.-(start)
    |> System.convert_time_unit(:native, :millisecond)
  end

  defp build_payload(prompt, options, tools, system_instruction) do
    payload = %{
      "contents" => [
        %{
          "role" => "user",
          "parts" => [%{"text" => prompt}]
        }
      ],
      "generationConfig" => NewsAgent.Gemini.generation_config(options)
    }

    payload
    |> maybe_put("tools", tools)
    |> maybe_put("systemInstruction", build_system_instruction(system_instruction))
  end

  defp build_system_instruction(nil), do: nil

  defp build_system_instruction(instruction) when is_binary(instruction) do
    %{
      "parts" => [%{"text" => instruction}]
    }
  end

  defp maybe_put(payload, _key, nil), do: payload
  defp maybe_put(payload, key, value), do: Map.put(payload, key, value)
end
