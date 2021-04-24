defmodule SnuflakeTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  doctest GlobalId

  describe "Snuflake.Application.get_id" do
    test "produces unique ids in order" do
      ids =
        Enum.map(0..1_000_000, fn _ ->
          Snuflake.Application.get_id()
        end)

      assert in_order(ids)
    end

    test "produces error message on wrong input" do
      log =
        capture_log([level: :error], fn ->
          id = Snuflake.Application.get_id()

          Snuflake.Application.get_id(id + 1_000_000)
        end)

      assert log |> String.contains?("Error generating GlobalId ")
    end
  end

  def in_order([_]) do
    true
  end

  def in_order([h1 | [h2 | _] = t]) when h1 < h2 do
    in_order(t)
  end

  def in_order(_) do
    false
  end
end
