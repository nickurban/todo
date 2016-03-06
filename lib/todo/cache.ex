defmodule Todo.Cache do
  use GenServer
  import String, only: [to_atom: 1]

  def save(list) do
    :ets.insert(__MODULE__, {to_atom(list.name), list})
  end

  def find(list_name) do
    case :ets.lookup(__MODULE__, to_atom(list_name)) do
      [{_id, value}] -> value
      [] -> nil
    end
  end

  def find_all do
    Enum.map(index, &find/1)
  end

  def index do
    build_index(:ets.first(__MODULE__), [])
  end

  defp build_index(key, acc) do
    if key == :"$end_of_table" do 
      acc
    else 
      next_key = :ets.next(__MODULE__, key) 
      build_index(next_key, [to_string(key) | acc])
    end
  end

  def clear do
    :ets.delete_all_objects(__MODULE__)
  end

  ###
  # GenServer API
  ###

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    table = :ets.new(__MODULE__, [:named_table, :public])
    {:ok, table}
  end
end
