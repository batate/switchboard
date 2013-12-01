defmodule PlugBuilderTest do
  use ExUnit.Case
  require Switchboard
  require Switchboard.PlugBuilder
  
  defmodule TestBoard do
    use Switchboard.PlugBuilder
    
    def inc(context, opts), do: {:ok, context + 1}
    def double(context, _), do: {:ok, context * 2}
    def clear(_, _), do: {:ok, 0}
    
    plug :clear
    plug {TestBoard, :inc}
    plug :double
  end
  
  test "should define plugs" do
    assert Enum.count( TestBoard.plugs ) == 3
  end
  
  test "should define stack with plugs" do
    stack = TestBoard.stack
    assert Enum.count( stack.plugs ) == 3
    assert stack.module == TestBoard
    assert Switchboard.Stack.call( stack, 1) == {:ok, 2}
  end
    
  
end