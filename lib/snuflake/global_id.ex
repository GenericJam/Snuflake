defmodule GlobalId do
  @moduledoc """
  GlobalId module contains an implementation of a guaranteed globally unique id system.

  Breakdown of pattern
  Time - 41
  10111100011111110010110101101101000101000
  Ids per node - 13
  1000000000000
  Node - 10
  1000000000
  """
  use Agent

  alias GlobalId

  require Logger

  defstruct(
    current_timestamp: 0,
    current_id: 0,
    node_id: 0
  )

  @type t :: %GlobalId{
          current_timestamp: integer(),
          current_id: integer(),
          node_id: integer()
        }

  @doc """
  What initialized state should look like
  """
  @spec initialize(non_neg_integer, non_neg_integer) :: GlobalId.t()
  def initialize(node_id, current_timestamp) do
    %GlobalId{
      current_timestamp: current_timestamp,
      current_id: 0,
      node_id: node_id
    }
  end

  @doc """
  Starts the Agent to initiate state
  """
  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(node_id) when node_id in 0..1023 do
    Agent.start_link(fn -> initialize(node_id, timestamp()) end, name: GlobalId)
  end

  @doc """
  Get an id with no error checking
  """
  @spec get_id :: non_neg_integer
  def get_id do
    get_id(0)
  end

  @doc """
  Please implement the following function.
  64 bit non negative integer output
  Will log an error if new id is not greater than the previous one
  """
  @spec get_id(non_neg_integer) :: non_neg_integer
  def get_id(last_id) do
    Agent.get(GlobalId, & &1)
    |> next_id(timestamp())
    |> update_id
    |> next_id_process
    |> check_error(last_id)
  end

  @doc """
  With the current state get the next id

  ## Examples

    iex>GlobalId.next_id(GlobalId.initialize(0, 1619304518324), 1619304518325)
    %GlobalId{current_id: 0, current_timestamp: 1619304518325, node_id: 0}

    iex>GlobalId.next_id(GlobalId.initialize(1023, 1619304518324), 1619304518325)
    %GlobalId{current_id: 0, current_timestamp: 1619304518325, node_id: 1023}

    iex>GlobalId.next_id(GlobalId.initialize(1023, 1619304518324), 1619304518324)
    %GlobalId{current_id: 1, current_timestamp: 1619304518324, node_id: 1023}

    iex>GlobalId.next_id(%GlobalId{
    ...>current_timestamp: 1619304518324,
    ...>current_id: 2046,
    ...>node_id: 0
    ...>}, 1619304518324)
    %GlobalId{current_id: 2047, current_timestamp: 1619304518324, node_id: 0}
  """
  @spec next_id(GlobalId.t(), non_neg_integer) :: GlobalId.t()
  def next_id(
        %GlobalId{
          current_timestamp: current_timestamp,
          current_id: current_id
        } = state,
        current_timestamp
      )
      when current_id < 8191 do
    %GlobalId{state | current_id: current_id + 1}
  end

  def next_id(
        %GlobalId{current_timestamp: prev_timestamp} = state,
        current_timestamp
      )
      when prev_timestamp < current_timestamp do
    %GlobalId{state | current_timestamp: current_timestamp, current_id: 0}
  end

  @spec update_id(GlobalId.t()) :: GlobalId.t()
  def update_id(%GlobalId{current_timestamp: current_timestamp, current_id: current_id} = state) do
    Agent.update(
      GlobalId,
      &%GlobalId{&1 | current_timestamp: current_timestamp, current_id: current_id}
    )

    state
  end

  @doc """
  With the current state get the next id

  ## Examples

    iex>state = GlobalId.initialize(1023, 1619300510744)
    iex>GlobalId.next_id_process(%GlobalId{ state |
    ...>current_id: 44
    ...>})
    13583677218831250431

  """
  @spec next_id_process(GlobalId.t()) :: integer
  def next_id_process(%GlobalId{
        current_timestamp: current_timestamp,
        current_id: current_id,
        node_id: node_id
      }) do
    <<(<<current_timestamp::41>>)::bitstring, <<current_id::13>>::bitstring,
      <<node_id::10>>::bitstring>>
    |> bitstring_to_integer
  end

  def bitstring_to_integer(<<value::64>>) do
    value
  end

  @doc """
  Log error if new id is not larger than the previous one
  No arg is 0 so that will always work
  """
  @spec check_error(integer(), integer()) :: integer() | :error
  def check_error(next_id, last_id) when next_id > last_id do
    next_id
  end

  def check_error(next_id, last_id) do
    Logger.error(
      "Error generating GlobalId next_id:#{inspect(next_id)} last_id:#{inspect(last_id)}"
    )

    next_id
  end

  #
  # You are given the following helper functions
  # Presume they are implemented - there is no need to implement them.
  #

  @doc """
  Returns your node id as an integer.
  It will be greater than or equal to 0 and less than or equal to 1024.
  It is guaranteed to be globally unique.
  """
  @spec node_id() :: non_neg_integer
  def node_id do
    %GlobalId{
      node_id: node_id
    } = Agent.get(GlobalId, & &1)

    node_id
  end

  @doc """
  Returns timestamp since the epoch in milliseconds.
  """
  @spec timestamp() :: non_neg_integer
  def timestamp do
    DateTime.utc_now() |> DateTime.to_unix(:millisecond)
  end
end
