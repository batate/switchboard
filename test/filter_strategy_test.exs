defmodule FilterStrategyTest do
  use ExUnit.Case
  require Switchboard

  defmodule Controller do
    def show(context, _), do: {:ok, context.assign(:invoke, :show)}
    def index(context, _), do: {:ok, context.assign(:invoke, :index)}
    def ensure(context, _) do
      {:ok, context.assign(:ensure, true)}
    end
  end

  def strategy do 
    Switchboard.Strategy.Filter.new controller: Controller, 
                                    action_function: &(Switchboard.Context.get(:action, &1)) 
  end

  def plug, do: Switchboard.Plug.Anon.new func: (fn(context, _) -> ({:ok, context.assign(:plug_invoked, "true")}) end)
  def filter, do: strategy.new_filter( plug, {:only, [:show]})
  def show_context, do: Switchboard.Context.new.assign(:action, :show)
  def index_context, do: Switchboard.Context.new.assign(:action, :index)
  def dispatch, do: strategy.new_dispatcher
  
  def stack, do: Switchboard.Stack.new plugs: [filter, dispatch], strategy: strategy, module: Controller
  
  test "should invoke plug", do: plug.(show_context)
  
  test "should invoke before filter" do
    {_, context} = stack.call(show_context)
    assert "true" == context.assigns[:plug_invoked]
  end
  
  test "should not before filter" do
    {_, context} = stack.call(index_context)
    assert nil == context.assigns[:plug_invoked]
  end
  
  test "should dispatch" do
    {_, context} = stack.call(index_context)
    assert context.assigns[:invoke] == :index
  end
  
  test "should invoke ensure" do
    {_, context} = stack.call(index_context)
    assert context.assigns[:ensure] == true
  end
  
end
