defmodule IfPlugTest do
  use ExUnit.Case
  
  
  def show_context, do: Switchboard.Context.new assigns: [action: :show]
  def index_context, do: Switchboard.Context.new assigns: [action: :index]

  def check_plug do
    Switchboard.Plug.new_from_mod_fun(func: :assign, module: __MODULE__)
  end
  
  def assign(context, _), do: {:ok, context.assign(:check, "function was called")}
  
  def ifplug do 
    Switchboard.Plug.IfPlug.new( check_plug, 
                                 &(Switchboard.Context.get :action, &1), 
                                 &Switchboard.Scheme.Filter.member?/2, 
                                 {:only, [:show]} )
  end
  
  test "should fire ifplug based on action being in only" do
    {:ok, result} = ifplug.( show_context )
    assert result.get( :check ) == "function was called"
  end
  
  test "should not fire ifplug based on action not being in only" do
    {:ok, result} = ifplug.( index_context )
    assert result.get( :check ) == nil
  end
    
  
end