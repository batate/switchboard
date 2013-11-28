defmodule HaltStrategyTest do
  use ExUnit.Case
  require Switchboard

  def inc(int, _), do: {:ok, int + 1}
  def halt(int, _), do: {:halt, int}

  def simple_plug, do: Switchboard.Plug.new_from_mod_fun func: :inc, module: __MODULE__
  def halt_plug, do: Switchboard.Plug.new_from_mod_fun func: :halt, module: __MODULE__
  def halt_stack do
    stack = Switchboard.Stack.new plugs: [simple_plug, halt_plug, simple_plug]
    stack.set_strategy Switchboard.Strategy.Halt
  end
  def haltless_stack, do: Switchboard.Stack.new plugs: [simple_plug, simple_plug]
  
  test "should halt stack",
    do: assert( halt_stack.call(0) == {:halt, 1} )
    
  test "should not halt stack", 
    do: assert( haltless_stack.call(0) == {:ok, 2} )
  
  
end
