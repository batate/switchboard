defmodule StackTest do
  use ExUnit.Case
  require Switchboard


  def plug, do: Switchboard.Plug.Anon.new func: &({:ok, &1 + 1})
  def stack, do: Switchboard.Stack.new plugs: [plug, plug]
  
  def handler, do: Switchboard.Stack.new plugs: [plug], name: "inc"
  def stack_with_handler, do: Switchboard.Stack.new plugs: [plug], handlers: [inc: handler]
  def child_stack, do: Switchboard.Stack.new plugs: [plug, plug], parent: stack_with_handler, name: "double"
  
  defmodule FunctionHandlerTest do
    def test(_, options // []), do: {:ok, "success"}
  end
  
  def stack_with_module, do: Switchboard.Stack.new module: FunctionHandlerTest, plugs: []

  test "should add a handler to stack" do
    added = stack.add_handler(handler)
    assert (added.handlers |> Enum.count) == 1
    assert added.handlers[ :inc ].name == "inc"
  end

  test "should set strategy" do
    changed = stack.set_strategy( Switchboard.Strategy.Filter.new )
    assert changed.strategy.controller == nil
  end
  
  test "should access parent's handlers" do
    assert child_stack.handler(:inc) == handler
  end
  
  test "should invoke function handler" do
    assert stack_with_module.module == FunctionHandlerTest
    assert stack_with_module.handle( :test, 1) == {:ok, "success"}
  end
end