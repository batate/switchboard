defmodule SwitchboardTest do
  use ExUnit.Case
  require Switchboard

  def inc(int), do: {:ok, int + 1}
  def double(int), do: {:ok, int * 2}
  def halt(int), do: {:halt, int}

  def simple_plug, do: Switchboard.Plug.Fun.new func: :inc, module: __MODULE__
  def double_plug, do: Switchboard.Plug.Fun.new func: :double, module: __MODULE__
  def halt_plug, do: Switchboard.Plug.Fun.new func: :halt, module: __MODULE__
  def stack, do: Switchboard.Stack.new plugs: [simple_plug, double_plug, double_plug]
  def halt_stack, do: Switchboard.Stack.new plugs: [simple_plug, halt_plug, double_plug]
  def handler, do: Switchboard.Stack.new plugs: [double_plug], name: "double"
  def stack_with_handler do
    Switchboard.Stack.new plugs: [double_plug], name: "handler", handlers: [double: handler]
  end
  
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
  
  test "should halt stack",
    do: assert( halt_stack.call(0) == {:halt, 1} )
    
  test "should call stack",
    do: assert( stack.call(2) == {:ok, 12} )

  test "should call module plug",
    do: assert( module_plug.call(2) == {:ok, 6} )
    
  test "should add to plug stack", 
    do: assert( (stack.add_plug(double_plug).plugs |> Enum.count) == 4 )

  test "should add a handler to stack" do
    added = stack.add_handler(handler)
    assert (added.handlers |> Enum.count) == 1
    assert Keyword.get( added.handlers, :double ).name == "double"
  end
    
  test "should handle tuple", 
    do: assert( stack_with_handler.handle({:double, 1}) == {:ok, 2})
  
  
end
