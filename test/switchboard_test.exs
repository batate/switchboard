defmodule SwitchboardTest do
  use ExUnit.Case
  require Switchboard

  def inc(int), do: {:ok, int + 1}
  def double(int), do: {:ok, int * 2}

  def simple_plug, do: Switchboard.Plug.Anon.new func: &({:ok, &1 + 1})
  def double_plug, do: Switchboard.Plug.Fun.new func: :double, module: __MODULE__

  defmodule WithPlugs do
    def simple_plug, do: Switchboard.Plug.Fun.new func: :inc, module: SwitchboardTest
    def double_plug, do: Switchboard.Plug.Fun.new func: :double, module: SwitchboardTest
    def stack, do: Switchboard.Stack.new plugs: [simple_plug, double_plug]
  end
  
  def module_plug, do: Switchboard.Plug.Mod.new(module: WithPlugs)
  
  test "should call simple plug", 
    do: assert( simple_plug.call(0) == {:ok, 1})

  test "should call plug with module", 
    do: assert( double_plug.call(1) == {:ok, 2})
    
  test "should name module", 
    do: assert( "with_plugs" == module_plug.name)
  
  test "should call module plug",
    do: assert( module_plug.call(2) == {:ok, 6} )
    
  test "should set context" do
    context = Switchboard.Context.new assigns: [color: :red]
    assert context.get(:color) == :red
    
    context = context.assign :color, :blue
    assert context.get(:color) == :blue
  end
    
end
