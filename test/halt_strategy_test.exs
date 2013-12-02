defmodule HaltStrategyTest do
  use ExUnit.Case
  import Should
  require Switchboard

  def inc(int, _), do: {:ok, int + 1}
  def halt(int, _), do: {:halt, int}

  def simple_plug, do: Switchboard.Plug.new_from_mod_fun func: :inc, module: __MODULE__
  def halt_plug, do: Switchboard.Plug.new_from_mod_fun func: :halt, module: __MODULE__
  def halt_stack do
    Switchboard.Stack.Entity.new( 
      plugs: [simple_plug, halt_plug, simple_plug], 
      strategy: Switchboard.Strategy.Halt )
  end
  def haltless_stack, do: Switchboard.Stack.Entity.new plugs: [simple_plug, simple_plug]
  
  should "halt stack",
    do: assert( Switchboard.Stack.call(halt_stack, 0) == {:halt, 1} )
    
  should "not halt stack", 
    do: assert( Switchboard.Stack.call(haltless_stack, 0) == {:ok, 2} )
end
