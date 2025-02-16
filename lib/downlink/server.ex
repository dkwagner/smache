defmodule Downlink.Server do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: Downlink)
  end

  def init(_state) do
    register()

    {:ok, %{}}
  end

  def find_dns(name) do
    uplink_provided = System.get_env("UPLINK_NODE")

    if uplink_provided != nil do
      uplink_provided
    else
      :os.cmd(:"
        nslookup #{name} \
        | grep Address \
        | head -2 \
        | tail -1 \
        | cut -d \":\" -f 2 \
        | tr -d \" \" \
        | tr -d \" \n\" \
        | tr -d \" \"
      ")
      |> to_string
    end
  end

  def resolved_node do
    uplink_node = find_dns("uplink")

    case uplink_node =~ "null" || uplink_node =~ "***" || uplink_node =~ "#" do
      true ->
        nil

      false ->
        if System.get_env("TEST"), do: nil, else: "smache@#{uplink_node}"
    end
  end

  defp register do
    node = :"#{resolved_node() || Node.self()}"

    Logger.warn("self: #{Node.self()} - uplink: #{node}")

    GenServer.call({Uplink, node}, {:sync, {}})
  end
end
