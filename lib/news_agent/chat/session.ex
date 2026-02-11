defmodule NewsAgent.Chat.Session do
  @moduledoc false

  use GenServer

  alias NewsAgent.Chat.LLM
  alias NewsAgent.UserConfigs

  @spec start_link({String.t(), keyword()}) :: GenServer.on_start()
  def start_link({chat_id, opts}) when is_binary(chat_id) and is_list(opts) do
    GenServer.start_link(__MODULE__, {chat_id, opts}, name: via_name(chat_id))
  end

  @spec handle_update(String.t(), map(), keyword()) ::
          {:ok, {String.t(), :pending | :linked}} | {:error, term()}
  def handle_update(chat_id, update, opts) when is_binary(chat_id) and is_map(update) do
    with {:ok, _pid} <- ensure_session(chat_id, opts) do
      timeout = session_timeout(opts)

      try do
        GenServer.call(via_name(chat_id), {:handle_update, update, opts}, timeout)
      catch
        :exit, {:timeout, _} -> {:error, :timeout}
        :exit, reason -> {:error, reason}
      end
    end
  end

  @doc """
  Resets the in-memory conversation history for a chat session.
  """
  @spec reset_context(String.t(), keyword()) :: :ok | {:error, term()}
  def reset_context(chat_id, opts) when is_binary(chat_id) and is_list(opts) do
    with {:ok, _pid} <- ensure_session(chat_id, opts) do
      timeout = session_timeout(opts)

      try do
        GenServer.call(via_name(chat_id), :reset_context, timeout)
      catch
        :exit, {:timeout, _} -> {:error, :timeout}
        :exit, reason -> {:error, reason}
      end
    end
  end

  @impl true
  def init({chat_id, _opts}) do
    {expires_at, ms_until} = next_expiration(chat_id)
    _ = Process.send_after(self(), :expire, ms_until)
    status = if chat_linked?(chat_id), do: :linked, else: :unknown
    {:ok, %{chat_id: chat_id, status: status, expires_at: expires_at, history: []}}
  end

  @impl true
  def handle_call({:handle_update, update, opts}, _from, state) do
    action = classify_action(state.status, update)
    log_action(state.chat_id, state.status, action, update)

    case action do
      :ignore_bot ->
        {:reply, {:ok, {nil, state.status}}, state}

      :ignore_no_text ->
        {:reply, {:ok, {nil, state.status}}, state}

      {:command, text} ->
        {reply, next_status, history} =
          handle_command(state.status, state.chat_id, text, opts, state.history)

        state = %{state | status: next_status, history: history}
        {:reply, reply, state}

      {:link_ok, text} ->
        {reply, next_status, history} =
          handle_text(state.status, state.chat_id, text, opts, state.history)

        state = %{state | status: next_status, history: history}
        {:reply, reply, state}

      {:link_prompt, text} ->
        {reply, next_status, history} =
          handle_text(state.status, state.chat_id, text, opts, state.history)

        state = %{state | status: next_status, history: history}
        {:reply, reply, state}

      {:llm, text} ->
        {reply, next_status, history} =
          handle_text(state.status, state.chat_id, text, opts, state.history)

        state = %{state | status: next_status, history: history}
        {:reply, reply, state}
    end
  end

  def handle_call(:reset_context, _from, state) do
    {:reply, :ok, %{state | history: []}}
  end

  @impl true
  def handle_info(:expire, state) do
    {:stop, :normal, state}
  end

  defp handle_text(:unknown, chat_id, text, opts, history) do
    if ok_message?(text) do
      link_chat(chat_id, opts, history)
    else
      {{:ok, {onboarding_prompt(), :pending}}, :pending, history}
    end
  end

  defp handle_text(:pending, chat_id, text, opts, history) do
    if ok_message?(text) do
      link_chat(chat_id, opts, history)
    else
      {{:ok, {onboarding_prompt(), :pending}}, :pending, history}
    end
  end

  defp handle_text(:linked, chat_id, text, opts, history) do
    log_llm_start(chat_id, text)

    case generate_reply(text, history, opts) do
      {:ok, reply} ->
        log_llm_success(chat_id, reply)
        history = append_history(history, text, reply)
        {{:ok, {reply, :linked}}, :linked, history}

      {:error, _reason} ->
        log_llm_error(chat_id)
        {{:ok, {"Sorry, I hit an error while responding.", :linked}}, :linked, history}
    end
  end

  defp onboarding_prompt do
    "Thanks! Reply OK to link this chat."
  end

  defp ok_message?(text) do
    text
    |> String.trim()
    |> String.upcase()
    |> then(&(&1 == "OK"))
  end

  defp build_prompt(text, history) do
    context =
      history
      |> Enum.map(fn {role, message} -> "#{role}: #{message}" end)
      |> Enum.join("\n")

    if context == "" do
      "You are a helpful assistant. Answer the user's message directly.\n\nUser message: #{text}"
    else
      "You are a helpful assistant. Use the conversation so far when it is relevant, and otherwise answer normally using general knowledge. If the user asks about earlier messages, use the conversation below.\n\nConversation so far:\n#{context}\n\nCurrent user message: #{text}"
    end
  end

  defp generate_reply(text, history, opts) do
    prompt = build_prompt(text, history)
    LLM.generate(prompt, opts)
  end

  defp append_history(history, user_text, reply) do
    max = history_limit()

    history
    |> Enum.concat([{"user", user_text}, {"assistant", reply}])
    |> Enum.take(-max)
  end

  defp link_chat(chat_id, opts, history) do
    case user_id(opts) do
      user_id when is_integer(user_id) and user_id > 0 ->
        case UserConfigs.update(user_id, %{chat_id: chat_id}) do
          {:ok, _record} ->
            {{:ok, {"Linked. You can start chatting.", :linked}}, :linked, history}

          {:error, :not_found} ->
            {{:ok, {"Please register in the app before linking this chat.", :pending}}, :pending,
             history}

          {:error, _reason} ->
            {{:ok, {"Linking failed. Please try again.", :pending}}, :pending, history}
        end

      _ ->
        {{:ok, {"Please register in the app before linking this chat.", :pending}}, :pending,
         history}
    end
  end

  defp command_message?(text) do
    String.starts_with?(String.trim(text), "/")
  end

  defp handle_command(status, _chat_id, text, _opts, history) do
    command =
      text
      |> String.trim()
      |> String.split()
      |> List.first()

    case command do
      "/start" ->
        if status == :linked do
          {{:ok, {"You are already linked.", :linked}}, :linked, history}
        else
          {{:ok, {onboarding_prompt(), :pending}}, :pending, history}
        end

      "/reset" ->
        if status == :linked do
          {{:ok, {"Context reset. You can continue chatting.", :linked}}, :linked, []}
        else
          {{:ok, {onboarding_prompt(), :pending}}, :pending, history}
        end

      "/help" ->
        {{:ok, {help_message(status), status}}, status, history}

      _ ->
        {{:ok, {"Unknown command. Use /help.", status}}, status, history}
    end
  end

  defp help_message(:linked) do
    "Available commands: /help"
  end

  defp help_message(_status) do
    "Reply OK to link this chat. Commands: /start, /help"
  end

  defp extract_text(update) do
    get_in(update, ["message", "text"]) ||
      get_in(update, ["edited_message", "text"]) ||
      get_in(update, ["channel_post", "text"])
  end

  defp from_bot?(update) do
    get_in(update, ["message", "from", "is_bot"]) == true or
      get_in(update, ["edited_message", "from", "is_bot"]) == true or
      get_in(update, ["channel_post", "from", "is_bot"]) == true
  end

  defp classify_action(status, update) do
    cond do
      from_bot?(update) ->
        :ignore_bot

      true ->
        case extract_text(update) do
          nil ->
            :ignore_no_text

          text ->
            cond do
              command_message?(text) ->
                {:command, text}

              status == :linked ->
                {:llm, text}

              ok_message?(text) ->
                {:link_ok, text}

              true ->
                {:link_prompt, text}
            end
        end
    end
  end

  defp log_action(chat_id, status, action, update) do
    require Logger

    text = extract_text(update)
    safe_text = if is_binary(text), do: truncate_text(text), else: ""

    Logger.debug(fn ->
      "Chat action chat_id=#{chat_id} status=#{status} action=#{inspect(action)} text=#{safe_text}"
    end)
  end

  defp truncate_text(text) do
    if String.length(text) > 160 do
      String.slice(text, 0, 160) <> "..."
    else
      text
    end
  end

  defp log_llm_start(chat_id, text) do
    require Logger

    Logger.debug(fn ->
      "Chat LLM start chat_id=#{chat_id} text=#{truncate_text(text)}"
    end)
  end

  defp log_llm_success(chat_id, reply) do
    require Logger

    Logger.debug(fn ->
      "Chat LLM success chat_id=#{chat_id} reply=#{truncate_text(reply)}"
    end)
  end

  defp log_llm_error(chat_id) do
    require Logger

    Logger.debug(fn ->
      "Chat LLM error chat_id=#{chat_id}"
    end)
  end

  defp ensure_session(chat_id, opts) do
    case Registry.lookup(NewsAgent.Chat.Registry, chat_id) do
      [{pid, _}] ->
        {:ok, pid}

      [] ->
        DynamicSupervisor.start_child(NewsAgent.Chat.Supervisor, {__MODULE__, {chat_id, opts}})
    end
  end

  defp via_name(chat_id) do
    {:via, Registry, {NewsAgent.Chat.Registry, chat_id}}
  end

  defp next_expiration(chat_id) do
    %{time: time, timezone: timezone} = default_chat_reset_config(chat_id)
    now = DateTime.now!(timezone)
    reset_at = next_reset_at(now, time, timezone)
    ms_until = max(DateTime.diff(reset_at, now, :millisecond), 0)
    {reset_at, ms_until}
  end

  defp history_limit do
    case System.get_env("NEWS_AGENT_CHAT_HISTORY_MAX") do
      value when is_binary(value) ->
        case Integer.parse(value) do
          {parsed, _} when parsed > 0 -> parsed
          _ -> 20
        end

      _ ->
        20
    end
  end

  defp next_reset_at(now, time, timezone) do
    reset_today = DateTime.new!(DateTime.to_date(now), time, timezone)

    case DateTime.compare(now, reset_today) do
      :lt -> reset_today
      _ -> DateTime.add(reset_today, 86_400, :second)
    end
  end

  defp session_timeout(opts) do
    case Keyword.get(opts, :session_timeout_ms) do
      value when is_integer(value) and value > 0 -> value
      _ -> 30_000
    end
  end

  defp user_id(opts) do
    value = Keyword.get(opts, :user_id) || System.get_env("NEWS_AGENT_DEFAULT_USER")

    cond do
      is_integer(value) and value > 0 ->
        value

      is_binary(value) ->
        case Integer.parse(String.trim(value)) do
          {parsed, _} when parsed > 0 -> parsed
          _ -> 1
        end

      true ->
        1
    end
  end

  defp chat_linked?(chat_id) do
    case UserConfigs.find_by_chat_id(chat_id) do
      {:ok, _record} -> true
      :error -> false
    end
  end

  defp default_chat_reset_config(_chat_id) do
    %{time: ~T[00:00:00], timezone: "Etc/UTC"}
  end
end
