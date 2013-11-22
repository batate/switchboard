defmodule SwitchboardTest do
  use ExUnit.Case
  require Switchboard

  def inc(int), do: {:ok, int + 1}
  def double(int), do: {:ok, int * 2}

  def simple_plug, do: Switchboard.Plug.Fun.new function_name: :inc, module: SwitchboardTest
  def double_plug, do: Switchboard.Plug.Fun.new function_name: :double, module: SwitchboardTest
  def stack, do: Switchboard.Stack.new plugs: [simple_plug, double_plug, double_plug]
  
  test "should call simple plug", 
    do: assert( simple_plug.call(0) == {:ok, 1})

  test "should call plug with module", 
    do: assert( double_plug.call(1) == {:ok, 2})
  
  test "should call stack",
    do: assert( stack.call(2) == {:ok, 12} )
    
  test "should add to plug stack", 
    do: assert( (stack.add(double_plug).plugs |> Enum.count) == 4 )
  
end
