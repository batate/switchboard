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
  def new(plug, action_fun, membership) do
    Switchboard.Plug.Fun.new func: :call, module: __MODULE__, args: [plug, action_fun, membership]
  end
  
  def call(context, plug, action_fun, membership) do
    test = context |> action_fun.() |> test(membership)
    _call plug, context, test
    
  end
  
  defp _call(plug, context, true), do: plug.call(context)
  defp _call(plug, context, false), do: {:ok, context}
  
  
  @doc """
  Tests whether the action matches.
  
  True if action is a member of :only, 

  """
  def test(action, membership), do: _test( action, (membership |> Enum.first) )
  
  defp _test( action, nil ), do: true
  defp _test( action, { :only, onlys } ), do: (action in onlys)
  defp _test( action, { :except, excepts} ), do: (not action in excepts)
  defp _test(_, _), do: raise "unsupported filter keyword"
end
