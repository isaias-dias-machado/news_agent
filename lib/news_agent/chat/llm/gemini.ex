defmodule NewsAgent.Chat.LLM.Gemini do
  @moduledoc false

  @behaviour NewsAgent.Chat.LLM.Provider

  alias Gemini
  require Logger

  @model "gemini-2.0-flash-lite"

  @impl true
  def generate(prompt, opts) when is_binary(prompt) do
    _ = System.fetch_env!("GEMINI_API_KEY")

    llm_opts = Keyword.get(opts, :llm_options, [])
    options = Keyword.merge([model: @model, max_output_tokens: 300, temperature: 0.3], llm_opts)

    generate_with_retry(prompt, options, retry_config(opts))
  end

  defp generate_with_retry(prompt, options, config) do
    do_generate_with_retry(
      prompt,
      options,
      config.retries,
      config.backoff_ms,
      config.timeout_ms,
      1
    )
  end

  defp do_generate_with_retry(prompt, options, retries, backoff_ms, timeout_ms, attempt) do
    Logger.debug(fn ->
      "Chat LLM attempt=#{attempt} timeout_ms=#{timeout_ms}"
    end)

    case generate_once(prompt, options, timeout_ms) do
      {:ok, text} ->
        {:ok, text}

      {:error, reason} ->
        if transient_error?(reason) and attempt <= retries do
          Logger.debug(fn ->
            "Chat LLM retry attempt=#{attempt} reason=#{inspect(reason)} backoff_ms=#{backoff_ms}"
          end)

          Process.sleep(backoff_ms)
          do_generate_with_retry(prompt, options, retries, backoff_ms, timeout_ms, attempt + 1)
        else
          log_non_retry(reason, attempt)

          Logger.debug(fn ->
            "Chat LLM failed attempts=#{attempt} reason=#{inspect(reason)}"
          end)

          {:error, reason}
        end
    end
  end

  defp generate_once(prompt, options, timeout_ms) do
    start = System.monotonic_time()
    task = Task.async(fn -> Gemini.generate(prompt, options) end)

    result =
      case Task.yield(task, timeout_ms) || Task.shutdown(task) do
        {:ok, value} ->
          value

        nil ->
          log_timeout(timeout_ms)

          if dev_env?() do
            raise "LLM timeout. Increase NEWS_AGENT_CHAT_LLM_TIMEOUT_MS"
          end

          {:error, :timeout}
      end

    with {:ok, response} <- result,
         {:ok, text} <- Gemini.extract_text(response) do
      text = String.trim(to_string(text))

      if text == "" do
        log_empty_response(start)
        {:error, :empty_response}
      else
        log_success(start, text)
        {:ok, text}
      end
    else
      {:error, reason} ->
        log_error(start, reason)
        {:error, reason}

      _ ->
        log_empty_response(start)
        {:error, :empty_response}
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

  defp transient_error?({:http_error, status, _body}) when is_integer(status) do
    status >= 500
  end

  defp transient_error?(%{reason: reason}) do
    transient_error?(reason)
  end

  defp transient_error?(%{status: status}) when is_integer(status) do
    status >= 500
  end

  defp transient_error?(:timeout), do: false
  defp transient_error?(:econnrefused), do: true
  defp transient_error?(:closed), do: true
  defp transient_error?(:nxdomain), do: true
  defp transient_error?(_), do: false

  defp dev_env? do
    case Code.ensure_loaded?(Mix) do
      true -> Mix.env() == :dev
      false -> System.get_env("NEWS_AGENT_ENV") == "dev"
    end
  end

  defp log_timeout(timeout_ms) do
    Logger.warning(fn -> "Chat LLM timeout timeout_ms=#{timeout_ms}" end)
  end

  defp log_success(start, text) do
    duration_ms = duration_ms(start)

    Logger.debug(fn ->
      "Chat LLM success duration_ms=#{duration_ms} chars=#{String.length(text)}"
    end)
  end

  defp log_error(start, reason) do
    duration_ms = duration_ms(start)

    Logger.warning(fn ->
      "Chat LLM error duration_ms=#{duration_ms} reason=#{inspect(reason)}"
    end)
  end

  defp log_empty_response(start) do
    duration_ms = duration_ms(start)
    Logger.warning(fn -> "Chat LLM empty_response duration_ms=#{duration_ms}" end)
  end

  defp log_non_retry(reason, attempt) do
    Logger.debug(fn ->
      "Chat LLM no_retry attempt=#{attempt} reason=#{inspect(reason)}"
    end)
  end

  defp duration_ms(start) do
    System.monotonic_time()
    |> Kernel.-(start)
    |> System.convert_time_unit(:native, :millisecond)
  end
end
