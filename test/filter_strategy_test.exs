defmodule FilterStrategyTest do
  use ExUnit.Case
  require Switchboard

  defmodule Controller do
    def show(context, opts // []), do: {:ok, context.assign(:invoke, :show)}
    def index(context, opts // []), do: {:ok, context.assign(:invoke, :index)}
    def ensure(context, opts // []) do
      {:ok, context.assign(:ensure, true)}
    end
  end

  def strategy do 
    Switchboard.Strategy.Filter.new controller: Controller, 
                                    action_function: &(Switchboard.Context.get(:action, &1)) 
  end

  def plug, do: Switchboard.Plug.Anon.new func: &({:ok, &1.assign(:plug_invoked, "true")})
  def filter, do: strategy.new_filter( plug, {:only, [:show]})
  def show_context, do: Switchboard.Context.new.assign(:action, :show)
  def index_context, do: Switchboard.Context.new.assign(:action, :index)
  def dispatch, do: strategy.new_dispatcher
  
  def stack, do: Switchboard.Stack.new plugs: [filter, dispatch], strategy: strategy, module: Controller
  
  
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
