defmodule PlugFactoryTest do
  use ExUnit.Case
  import Should
  require Switchboard

  def inc(int, _), do: {:ok, int + 1}

  defmodule Double do
    def stack(parent_chain // []) do
      Switchboard.Stack.Entity.new plugs: [
        Switchboard.Plug.Factory.build_plug( __MODULE__, {PlugFactoryTest, :inc}, []), 
        Switchboard.Plug.Factory.build_plug( __MODULE__, {PlugFactoryTest, :inc}, []) ], 
                                   parent_chain: parent_chain
    end
    
    def inc(context, _), do: {:ok, context + 1}
  end

  defmodule Plugs do
    def double(int, _), do: {:ok, int * 2}
    
    def stack(_ // nil) do 
      Switchboard.Stack.Entity.new(
        module: __MODULE__, 
        plugs: [ 
          Switchboard.Plug.Factory.build_plug(Plugs, :double, []), 
          Switchboard.Plug.Factory.build_plug(Plugs, :double , []) ], 
        handlers: [double_inc: Double.stack] )
    end
    
    def call(context, _), do: Switchboard.Stack.call(stack, context, :ok)
  end

  def module_plug, do: Switchboard.Plug.Factory.build_plug(Plugs, Double, [])
  
  should "invoke basic plug" do
    plug = Enum.first(Plugs.stack.plugs)
    assert plug.(1) == {:ok, 2}
  end
  
  should "invoke anon function plug" do
    plug = Switchboard.Plug.Factory.build_plug( PlugFactoryTest, &PlugFactoryTest.inc/2, [] ) 
    assert plug.(1) == {:ok, 2}
  end
  
  should "invoke mod/function plug" do
    plug = Switchboard.Plug.Factory.build_plug( PlugFactoryTest, {PlugFactoryTest, :inc}, [] ) 
    assert plug.(1) == {:ok, 2}
  end
  
  should "invoke module plug" do
    plug = Switchboard.Plug.Factory.build_plug( PlugFactoryTest, Plugs, [] ) 
    assert plug.(1) == {:ok, 4}
  end
  
  should "invoke atom handler plug as function" do
    plug = Switchboard.Plug.Factory.build_plug( Plugs, :double, [] ) 
    assert plug.(2) == {:ok, 4}
  end
  
  should "invoke atom handler plug as stack" do
    plug = Switchboard.Plug.Factory.build_plug( Plugs, :double_inc, [] ) 
    assert plug.(1) == {:ok, 3}
  end
end