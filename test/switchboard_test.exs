defmodule SwitchboardTest do
  use ExUnit.Case
  import Should
  require Switchboard

  def inc(int, _), do: {:ok, int + 1}
  def double(int, _), do: {:ok, int * 2}

  def simple_plug, do: Switchboard.Plug.new_from_anon func: (fn(x, _) -> {:ok, x + 1} end)
  def double_plug, do: Switchboard.Plug.new_from_mod_fun func: :double, module: __MODULE__

  defmodule WithPlugs do
    def simple_plug, do: Switchboard.Plug.new_from_mod_fun func: :inc, module: SwitchboardTest
    def double_plug, do: Switchboard.Plug.new_from_mod_fun func: :double, module: SwitchboardTest
    def stack(_), do: Switchboard.Stack.Entity.new plugs: [simple_plug, double_plug]
  end
  
  def module_plug, do: Switchboard.Plug.new_from_module(module: WithPlugs)
  
  should "call simple plug", 
    do: assert( simple_plug.(0) == {:ok, 1})

  should "call plug with module", 
    do: assert( double_plug.(1) == {:ok, 2})
    
  should "call module plug",
    do: assert( module_plug.(2) == {:ok, 6} )
    
  should "set context" do
    context = Switchboard.Context.new assigns: [color: :red]
    assert context.get(:color) == :red
    
    context = context.assign :color, :blue
    assert context.get(:color) == :blue
  end
    
end
