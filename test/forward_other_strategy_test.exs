defmodule ForwardOtherStrategyTest do
  use ExUnit.Case
  require Switchboard

  def inc(int, _), do: {:ok, int + 1}
  def double(int, _), do: {:ok, int * 2}
  def halt(int, _), do: {:halt, int}

  def simple_plug, do: Switchboard.Plug.new_from_mod_fun func: :inc, module: __MODULE__
  def double_plug, do: Switchboard.Plug.new_from_mod_fun func: :double, module: __MODULE__
  def halt_plug, do: Switchboard.Plug.new_from_mod_fun func: :halt, module: __MODULE__
  def stack, do: Switchboard.Stack.new plugs: [simple_plug, double_plug, double_plug]
  def halt_stack, do: Switchboard.Stack.new plugs: [simple_plug, halt_plug, double_plug]
  def handler, do: Switchboard.Stack.new plugs: [double_plug], name: "double"
  def stack_with_handler do
    Switchboard.Stack.new plugs: [double_plug], name: "handler", handlers: [double: handler]
  end
  
  defmodule WithPlugs do
    def simple_plug, do: Switchboard.Plug.new_from_mod_fun func: :inc, module: ForwardOtherStrategyTest
    def double_plug, do: Switchboard.Plug.new_from_mod_fun func: :double, module: ForwardOtherStrategyTest
    def stack, do: Switchboard.Stack.new plugs: [simple_plug, double_plug]
  end
  
  def module_plug, do: Switchboard.Plug.new_from_module(module: WithPlugs)
  
  test "should halt stack",
    do: assert( halt_stack.call(0) == {:halt, 1} )
    
  test "should call stack",
    do: assert( stack.call(2) == {:ok, 12} )

  test "should call module plug",
    do: assert( module_plug.(2) == {:ok, 6} )
    
  test "should handle tuple", 
    do: assert( stack_with_handler.handle(:double, 1) == {:ok, 2})
end
