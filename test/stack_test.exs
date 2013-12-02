defmodule StackTest do
  use ExUnit.Case
  import Should
  require Switchboard


  def plug, do: Switchboard.Plug.new_from_anon func: &({:ok, &1 + 1})
  def stack, do: Switchboard.Stack.Entity.new plugs: [plug, plug]
  
  defmodule Inc do
    def plugs(_ // nil), do: [StackTest.plug]
    def stack(_ // nil), do: Switchboard.Stack.Entity.new plugs: plugs
  end
  
  def handler, do: Inc
  def stack_with_handler, do: Switchboard.Stack.Entity.new plugs: [plug], handlers: [inc: handler]
  def child_stack, do: Switchboard.Stack.Entity.new plugs: [plug, plug], parent_chain: [StackTest.Handler], name: "double"
  
  defmodule Handler do
    def stack(parent_chain), do: StackTest.stack_with_handler.update(parent_chain: parent_chain)
  end
  
  defmodule FunctionHandlerTest do
    def test(_, _), do: {:ok, "success"}
  end
  
  def stack_with_module, do: Switchboard.Stack.Entity.new module: FunctionHandlerTest, plugs: []

  should "access a handler", 
    do: assert Inc == Switchboard.Stack.handler( stack_with_handler, :inc)

  should "access parent's handlers" do
    assert Switchboard.Stack.handler(child_stack, :inc) == handler
  end
  
  should "invoke function handler" do
    assert stack_with_module.module == FunctionHandlerTest
    assert Switchboard.Stack.handle( stack_with_module, :test, 1) == {:ok, "success"}
  end
end