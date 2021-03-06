defmodule Store.Event do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @params ~w(type user_id tenant_id content data date external_id)a
  @required_params ~w(type user_id tenant_id content date external_id)a

  @derive {Poison.Encoder,
           only: [
             :type,
             :user_id,
             :external_id,
             :tenant_id,
             :content,
             :data,
             :date,
             :inserted_at
           ]}

  schema "events" do
    field(:type, :string)
    field(:user_id, :integer)
    field(:external_id, :integer)
    field(:tenant_id, :integer)
    field(:content, :string)
    field(:data, :map)
    field(:date, :naive_datetime)

    timestamps()
  end

  def changeset(event, params \\ %{}) do
    params = convert_date(params)

    event
    |> cast(params, @params)
    |> validate_required(@required_params)
  end

  defp convert_date(%{"date" => date} = params) when is_number(date) do
    Map.put(params, "date", DateTime.from_unix!(date))
  end

  defp convert_date(%{"date" => date} = params) do
    {:ok, date, _utc_offset} = DateTime.from_iso8601(date)
    Map.put(params, "date", date)
  end
end
