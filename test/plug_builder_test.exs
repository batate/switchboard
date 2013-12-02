
defmodule PlugBuilderTest do
  use ExUnit.Case
  import Should


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
  
  should "define plugs" do
    assert Enum.count( TestBoard.plugs ) == 3
  end
  
  should "define stack with plugs" do
    stack = TestBoard.stack
    assert Enum.count( stack.plugs ) == 3
    assert stack.module == TestBoard
    assert Switchboard.Stack.call( stack, 1) == {:ok, 2}
  end
  
  should "assign a strategy", do: 
    assert TestBoard.stack.strategy == Switchboard.Strategy.Halt
    
  should "define a handler", do:
    assert Enum.count(TestBoard.stack.handlers) == 1
    
  # ---------------------------------------------------
  # tests to check parent assignment and handler access
  # ---------------------------------------------------

  defmodule MarkMe do
    use Switchboard.PlugBuilder

    plug :mark_it
    
    def mark_it(_, _), do: {:ok, :marked}
  end

  defmodule Parent do
    use Switchboard.PlugBuilder
    plug PlugBuilderTest.Child
    
    on :mark, MarkMe
  end  
  
  defmodule Child do
    use Switchboard.PlugBuilder
    plug :handle_mark
    
    def handle_mark(context, _), do: {:mark, context}
  end
  
  should "navigate parent chain", do:
    assert Switchboard.Stack.call( Parent.stack, "") == {:halt, :marked}
end