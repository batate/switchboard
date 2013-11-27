defmodule Switchboard.Plug.IfPlug do
  @doc """
  A plug that wraps a second plug. 
  
  Conceptually, the plug
  
  - gets an attribute from the connection
  - determines a test based on options passed into the connection
  - calls the wrapped plug if the test is true
  - passes through {:ok, context} if the test is false

  """

  @doc """
  Creates a new ifplug. This plug is a module, not a record. 

  """
  def new(plug, action_fun, comparison_fun, args) do
    Switchboard.Plug.Fun.new func: :call, module: __MODULE__, args: [plug, action_fun, comparison_fun, args]
  end
  
  def call(context, plug, action_fun, comparison_fun, args) do
    test = context |> action_fun.() |> comparison_fun.( args )
    _call plug, context, test
  end
  
  defp _call(plug, context, true), do: plug.call(context)
  defp _call(_, context, false), do: {:ok, context}
  
end