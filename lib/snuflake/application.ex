defmodule Snuflake.Application do
  @moduledoc """
  Snuflake makes ids
  """
  use Application

  require Logger

  def start(node_id \\ 0) when node_id in 0..1023 do
    GlobalId.start_link(node_id)
  end

  def get_id do
    GlobalId.get_id()
  end

  def get_id(last_id) do
    GlobalId.get_id(last_id)
  end
end
