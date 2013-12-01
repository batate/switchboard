defmodule PlugBuilderTest do
  use ExUnit.Case
  require Switchboard
  require Switchboard.PlugBuilder


  defmodule Triple do
    use Switchboard.PlugBuilder
    
    plug :triple
    
    def triple(context, _), do: {:ok, context * 3}
  end
  
  defmodule TestBoard do
    use Switchboard.PlugBuilder
    strategy Switchboard.Strategy.Halt
    
    plug :clear
    plug {TestBoard, :inc}
    plug :double

    on :triple_it, Triple
    
    def inc(context, _), do: {:ok, context + 1}
    def double(context, _), do: {:ok, context * 2}
    def clear(_, _), do: {:ok, 0}

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
  
  test "should assign a strategy", do: 
    assert TestBoard.stack.strategy == Switchboard.Strategy.Halt
    
  test "should define a handler", do:
    assert Enum.count(TestBoard.stack.handlers) == 1
  
end