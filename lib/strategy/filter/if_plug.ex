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
  def new(plug, action_fun, comparison_fun, options) do
    Switchboard.Plug.Fun.new func: :call, module: __MODULE__, 
                             options: [plug: plug, 
                                       action_fun: action_fun, 
                                       comparison_fun: comparison_fun, 
                                       comparison_args: options]
  end
  
  def call(context, options) do
    test = context |> options[:action_fun].() |> options[:comparison_fun].( options[:comparison_args] )
    _call options[:plug], context, test
  end
  
  defp _call(plug, context, true), do: plug.(context)
  defp _call(_, context, false), do: {:ok, context}
  
end