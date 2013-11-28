defrecord Switchboard.Strategy.Halt, module: nil do
  
  
  @doc """
  Calls this stack. 

  Consider a stack with the plugs [plug1, plug2, plug3],
  all of which return {:ok, context}. 
  
  
  context |> plug1 |> plug2 |> plug3
  
  The traversal will halt if the result is :halt, and resume otherwise. 

  Consider the stack with the plugs [plug1, plug2, plug3], 
  where plug2 returns {:halt, context}. In this case, invoking the 
  stack would give you the composition:
  
  context |> plug1 |> plug 2
  
  Any return code other than :halt will be passed through. 
  
  """
  def call({code, context}, stack), do: _call({code, context}, stack.plugs)
  
  defp _call({:halt, context}, _), do: {:halt, context}
  defp _call(code, []), do: code
  defp _call({code, context}, [plug|tail]) do
    _call(plug.(context), tail) 
  end
  
  
end