defmodule HaltStrategyTest do
  use ExUnit.Case
  require Switchboard

  def inc(int, _), do: {:ok, int + 1}
  def halt(int, _), do: {:halt, int}

  def simple_plug, do: Switchboard.Plug.new_from_mod_fun func: :inc, module: __MODULE__
  def halt_plug, do: Switchboard.Plug.new_from_mod_fun func: :halt, module: __MODULE__
  def halt_stack do
    stack = Switchboard.Stack.Entity.new plugs: [simple_plug, halt_plug, simple_plug]
    Switchboard.Stack.set_strategy stack, Switchboard.Strategy.Halt
  end
  def haltless_stack, do: Switchboard.Stack.Entity.new plugs: [simple_plug, simple_plug]
  
  test "should halt stack",
    do: assert( Switchboard.Stack.call(halt_stack, {:ok, 0}) == {:halt, 1} )
    
  test "should not halt stack", 
    do: assert( Switchboard.Stack.call(haltless_stack, {:ok, 0}) == {:ok, 2} )
  
  
end
