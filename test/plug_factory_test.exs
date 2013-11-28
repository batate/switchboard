defmodule PlugFactoryTest do
  use ExUnit.Case
  require Switchboard
  import Switchboard.Plug.Factory

  def inc(int, _), do: {:ok, int + 1}
  
  
  def simple_plug, do: Switchboard.Plug.new_from_anon func: (fn(x, _) -> {:ok, x  * 3} end)

  defmodule Plugs do
    def double(int, _), do: {:ok, int * 2}
    
    def stack do 
      Switchboard.Stack.new(
        plugs: [PlugFactoryTest.simple_plug, PlugFactoryTest.simple_plug] )
      end
  end
  
  def stack, do: Switchboard.Stack.new module: Plugs, handlers: [trips: handler]
  def handler, do: Switchboard.Stack.new plugs: [simple_plug], name: :trips
  
  test "should invoke function plug from atom" do
    new_stack = plug( stack, :double )
    assert Enum.count(new_stack.plugs) == 1
    assert new_stack.call({:ok, 1}) == {:ok, 2}
  end
  
  test "should invoke handler plug from atom" do
    new_stack = plug( stack, :trips )
    assert Enum.count(new_stack.plugs) == 1
    assert new_stack.call({:ok, 1}) == {:ok, 3}
  end
  
  test "should invoke module plug" do
    new_stack = plug( stack, Plugs )
    assert Enum.count(new_stack.plugs) == 1
    assert new_stack.call({:ok, 1}) == {:ok, 9}
  end
  
  test "should invoke function plug" do
    new_stack = plug( stack, &__MODULE__.inc/2 )
    assert Enum.count(new_stack.plugs) == 1
    assert new_stack.call({:ok, 1}) == {:ok, 2}
  end
  
  test "should invoke tuple plug" do
    new_stack = plug( stack, {__MODULE__, :inc} )
    assert Enum.count(new_stack.plugs) == 1
    assert new_stack.call({:ok, 1}) == {:ok, 2}
  end
  
  
  
  
end