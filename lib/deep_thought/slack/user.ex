defmodule DeepThought.Slack.User do
  @moduledoc """
  Module struct for representing the database-cached data of a Slack user. Not all fields are used for translation
  purposes, but they are collected for possible future analytics use.
  """
  use Ecto.Schema
  alias DeepThought.Slack.User
  import Ecto.Changeset

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          display_name: String.t() | nil,
          display_name_normalized: String.t() | nil,
          email: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          real_name: String.t() | nil,
          real_name_normalized: String.t() | nil,
          user_id: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }
  schema "slack_users" do
    field :display_name, :string
    field :display_name_normalized, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :real_name, :string
    field :real_name_normalized, :string
    field :user_id, :string

    timestamps()
  end

  @doc """
  Given a Slack user, return a user-friendly username of that user. Prefers real name over display name.
  """
  @spec display_name(User.t()) :: String.t()
  def display_name(%{real_name: real_name}), do: real_name
  def display_name(%{display_name: display_name}), do: display_name
  def display_name(_), do: "unknown user"

  @doc """
  Changeset for upserting users based on data obtained from Slack API.
  """
  @spec changeset(User.t(), map()) :: Ecto.Changeset.t()
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :user_id,
      :email,
      :real_name,
      :real_name_normalized,
      :display_name,
      :display_name_normalized,
      :last_name,
      :first_name
    ])
    |> validate_required([:user_id])
    |> unique_constraint([:user_id])
  end
end
