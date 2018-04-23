defmodule Smache.Supervisor do
  alias Smache.Ets.Table, as: EtsTable
  alias Smache.Shard, as: Shard
  alias Downlink.Server, as: Downlink
  alias Uplink.Server, as: Uplink

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    ets_table_names = Shard.tables(:ets)

    children =
      ets_table_names
      |> Enum.map(fn name ->
        worker(EtsTable, [[name: name]], id: name)
      end)

    all_children =
      [
        worker(Uplink, [UplinkServer]),
        worker(Downlink, [DownlinkServer])
      ] ++ children

    supervise(all_children, strategy: :one_for_one)
  end
end
