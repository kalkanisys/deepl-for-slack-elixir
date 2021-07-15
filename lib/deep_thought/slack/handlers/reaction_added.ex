defmodule DeepThought.Slack.Handler.ReactionAdded do
  @moduledoc """
  Module responsible for handling the `reaction_added` Slack event, which is received when user adds a reaction emoji to
  a message. This might be a normal emoji, or a flag emoji, which would indicate the desire to translate the message to
  another language.
  """

  alias DeepThought.DeepL
  alias DeepThought.Slack
  alias DeepThought.Slack.API.{ContextBlock, Message, SectionBlock, Text}
  alias DeepThought.Slack.{Language, MessageEscape}

  @doc """
  Take event details, interpret the details, if the event points to a translation request, fetch the message details,
  translate the message text and post the translation in thread.
  """
  @typep reason() :: :unknown_language | non_neg_integer() | atom()
  @spec reaction_added(map()) :: {:ok, String.t()} | {:error, reason()}
  def reaction_added(%{
        "item" => %{"channel" => channel_id, "ts" => message_ts, "type" => "message"},
        "reaction" => reaction
      }) do
    with {:ok, %{deepl_code: language_code}} <- Language.new(reaction),
         {:ok, [%{"text" => original} = message | _]} <-
           Slack.API.conversations_replies(channel_id, message_ts),
         escaped_original <- MessageEscape.escape(original),
         {_, translation} <- DeepL.API.translate(escaped_original, language_code),
         :ok <- say_in_thread(channel_id, translation, message) do
      {:ok, translation}
    else
      error -> error
    end
  end

  @spec say_in_thread(String.t(), String.t(), map()) :: :ok | {:error, atom()}
  defp say_in_thread(channel_id, translation, message) do
    reply =
      Message.new(translation, channel_id)
      |> Message.in_thread(extract_thread_ts(message))
      |> Message.unescape()

    Message.add_block(reply, translation_block(reply.text))
    |> Message.add_block(footer_block(channel_id, message))
    |> Slack.API.chat_post_message()
  end

  @spec extract_thread_ts(map()) :: String.t()
  defp extract_thread_ts(%{"thread_ts" => thread_ts}), do: thread_ts
  defp extract_thread_ts(%{"ts" => ts}), do: ts

  @spec translation_block(String.t()) :: SectionBlock.t()
  defp translation_block(translation),
    do:
      SectionBlock.new()
      |> SectionBlock.with_text(Text.new(translation))

  @spec footer_block(String.t(), map()) :: ContextBlock.t()
  defp footer_block(channel_id, message),
    do:
      ContextBlock.new()
      |> ContextBlock.with_text(Text.new(generate_permalink(channel_id, message)))

  @spec generate_permalink(String.t(), map()) :: String.t()
  defp generate_permalink(channel_id, %{"ts" => message_ts}) do
    case Slack.API.chat_get_permalink(channel_id, message_ts) do
      {:ok, permalink} -> "<" <> permalink <> "|View original message>"
      _ -> "⚠️ Could not find original message"
    end
  end
end
