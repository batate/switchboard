defmodule Switchboard.Strategy.ForwardOther do
  
  
  @doc """
  Calls this stack. 

  Consider a stack with the plugs [plug1, plug2, plug3],
  all of which return {:ok, context}. 
  
  
  context |> plug1 |> plug2 |> plug3
  
  The traversal will halt if the result is anything other than :ok. 
  Consider the stack with the plugs [plug1, plug2, plug3], 
  where plug2 returns {:halt, context}. In this case, invoking the 
  stack would give you the composition:
  
  context |> plug1 |> plug 2
  
  """
  def call(context, stack), do: _call({:ok, context}, stack.plugs, stack)

  defp _call({:ok, context}, [plug|tail], stack) do
    _call(plug.call(context), tail, stack) 
  end
    
  defp _call({:ok, context}, [], _), do: {:ok, context}
  defp _call({:halt, context}, _, _), do: {:halt, context}
  defp _call(result, _, stack), do: handle(result, stack)

  @doc """
  Handles return codes other than {:ok, _} and {:halt, _}
  """
  def handle({code, context}, stack) do
    handler = Keyword.get stack.handlers, code
    _handle code, context, handler
  end
  
  defp _handle(code, context, nil), do: {code, context}
  defp _handle(code, context, plug), do: plug.call context 
  
end