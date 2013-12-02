defmodule FilterStrategyTest do
  use ExUnit.Case
  import Should
  require Switchboard

  defmodule Controller do
    def show(context, _), do: {:ok, context.assign(:invoke, :show)}
    def index(context, _), do: {:ok, context.assign(:invoke, :index)}
    def ensure(context, _) do
      {:ok, context.assign(:ensure, true)}
    end
  end

  def scheme do 
    Switchboard.Scheme.Filter.Entity.new controller: Controller, 
                                    action_function: &(Switchboard.Context.get(:action, &1)) 
  end
  
  def strategy, do: Switchboard.Strategy.Halt
  

  def plug, do: Switchboard.Plug.new_from_anon func: (fn(context, _) -> ({:ok, context.assign(:plug_invoked, "true")}) end)
  def filter, do: Switchboard.Scheme.Filter.new_filter(scheme, plug, {:only, [:show]})
  def show_context, do: Switchboard.Context.new.assign(:action, :show)
  def index_context, do: Switchboard.Context.new.assign(:action, :index)
  def dispatch, do: Switchboard.Scheme.Filter.new_dispatcher scheme
  
  def stack, do: Switchboard.Stack.Entity.new plugs: [filter, dispatch], strategy: strategy, module: Controller
  
  # should "invoke plug", do: plug.(show_context)
  # 
  # should "invoke before filter" do
  #   {_, context} = Switchboard.Stack.call(stack, show_context)
  #   assert "true" == context.assigns[:plug_invoked]
  # end
  # 
  # should "not before filter" do
  #   {_, context} = Switchboard.Stack.call(stack, index_context)
  #   assert nil == context.assigns[:plug_invoked]
  # end
  # 
  # should "dispatch" do
  #   {_, context} = Switchboard.Stack.call(stack, index_context)
  #   assert context.assigns[:invoke] == :index
  # end
  # 
  should "invoke ensure" do
    {_, context} = Switchboard.Stack.call(stack, index_context)
    assert context.assigns[:ensure] == true
  end
  
end
