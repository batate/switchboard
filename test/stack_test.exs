defmodule StackTest do
  use ExUnit.Case
  require Switchboard


  def plug, do: Switchboard.Plug.new_from_anon func: &({:ok, &1 + 1})
  def stack, do: Switchboard.Stack.Entity.new plugs: [plug, plug]
  
  def handler, do: Switchboard.Stack.Entity.new plugs: [plug], name: "inc"
  def stack_with_handler, do: Switchboard.Stack.Entity.new plugs: [plug], handlers: [inc: handler]
  def child_stack, do: Switchboard.Stack.Entity.new plugs: [plug, plug], parent: stack_with_handler, name: "double"
  
  defmodule FunctionHandlerTest do
    def test(_, _), do: {:ok, "success"}
  end
  
  def stack_with_module, do: Switchboard.Stack.Entity.new module: FunctionHandlerTest, plugs: []

  test "should add a handler to stack" do
    added = Switchboard.Stack.add_handler(stack, handler)
    assert (added.handlers |> Enum.count) == 1
    assert added.handlers[ :inc ].name == "inc"
  end

  test "should set strategy" do
    changed = Switchboard.Stack.set_strategy( stack, Switchboard.Strategy.Filter.new )
    assert changed.strategy.controller == nil
  end
  
  test "should access parent's handlers" do
    assert Switchboard.Stack.handler(child_stack, :inc) == handler
  end
  
  test "should invoke function handler" do
    assert stack_with_module.module == FunctionHandlerTest
    assert Switchboard.Stack.handle( stack_with_module, :test, 1) == {:ok, "success"}
  end
end