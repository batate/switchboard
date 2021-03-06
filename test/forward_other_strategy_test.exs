defmodule ForwardOtherStrategyTest do
  use ExUnit.Case
  import Should
  require Switchboard

  def inc(int, _), do: {:ok, int + 1}
  def double(int, _), do: {:ok, int * 2}
  def halt(int, _), do: {:halt, int}

  def simple_plug, do: Switchboard.Plug.new_from_mod_fun func: :inc, module: __MODULE__
  def double_plug, do: Switchboard.Plug.new_from_mod_fun func: :double, module: __MODULE__
  def halt_plug, do: Switchboard.Plug.new_from_mod_fun func: :halt, module: __MODULE__
  def stack(_ // []), do: Switchboard.Stack.Entity.new plugs: [simple_plug, double_plug, double_plug], name: :stack
  def halt_stack, do: Switchboard.Stack.Entity.new plugs: [simple_plug, halt_plug, double_plug], name: :halt_stack
  def handler, do: Switchboard.Stack.Entity.new plugs: [double_plug], name: :double_stack
  def stack_with_handler do
    Switchboard.Stack.Entity.new plugs: [double_plug], name: "handler", handlers: [double: handler]
  end
  
  defmodule WithPlugs do
    def simple_plug, do: Switchboard.Plug.new_from_mod_fun func: :inc, module: ForwardOtherStrategyTest
    def double_plug, do: Switchboard.Plug.new_from_mod_fun func: :double, module: ForwardOtherStrategyTest
    def stack(_ // []), do: Switchboard.Stack.Entity.new plugs: [simple_plug, double_plug]
  end
  
  def module_plug, do: Switchboard.Plug.new_from_module(module: WithPlugs)
  
  should "halt stack",
    do: assert( Switchboard.Stack.call(halt_stack, 0) == {:halt, 1} )
    
  should "call stack",
    do: assert( Switchboard.Stack.call(stack, 2) == {:ok, 12} )

  should "call module plug",
    do: assert( module_plug.(2) == {:ok, 6} )
    
  should "handle tuple" do
    assert( Switchboard.Stack.handle(stack_with_handler, :double, 1) == {:ok, 2})
  end
end
