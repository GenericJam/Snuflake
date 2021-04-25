defmodule Snuflake.Application do
  @moduledoc """
  Snuflake makes ids
  """
  use Application

  require Logger

  # Set this to change the node_id or pass it in as an arg
  @node_id 0

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, node_id: node_id) when node_id in 0..1023 do
    GlobalId.start_link(node_id)
  end

  def start(_type, _args) do
    GlobalId.start_link(@node_id)
  end

  @spec get_id :: non_neg_integer
  def get_id do
    GlobalId.get_id()
  end

  @spec get_id(non_neg_integer) :: non_neg_integer
  def get_id(last_id) do
    GlobalId.get_id(last_id)
  end
end
