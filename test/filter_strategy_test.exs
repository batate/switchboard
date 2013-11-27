defmodule FilterStrategyTest do
  use ExUnit.Case
  require Switchboard
  import Switchboard

  defmodule Controller do
    def show(context, opts // []), do: {:render, context.assign(:render, context.assign(:invoke, :show))}
    def index(context, opts // []), do: {:render, context.assign(:render, context.assign(:invoke, :index))}
  end

  def strategy do 
    Switchboard.Strategy.Filter.new controller: Controller, 
                                    action_function: &(Switchboard.Context.get(:action, &1)) 
  end

  def plug, do: Switchboard.Plug.Anon.new func: &({:ok, &1.assign(:plug_invoked, "true")})
  def filter, do: strategy.new_filter( plug, {:only, [:show]})
  def show_context, do: Switchboard.Context.new.assign(:action, :show)
  def index_context, do: Switchboard.Context.new.assign(:action, :index)
  
  def stack, do: Switchboard.Stack.new plugs: [filter], strategy: strategy
  
  
  test "should invoke before filter" do
    {code, context} = stack.call(show_context)
    assert "true" == context.assigns[:plug_invoked]
  end
  
  test "should not before filter" do
    {code, context} = stack.call(index_context)
    assert nil == context.assigns[:plug_invoked]
  end
  
end
