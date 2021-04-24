defmodule Snuflake.Application do
  use Application

  require Logger

  def start(_type, _args) do
    GlobalId.start_link(0)
  end

  def get_id do
    GlobalId.get_id()
  end

  def get_id(last_id) do
    GlobalId.get_id(last_id)
  end
end
