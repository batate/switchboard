defrecord Switchboard.Stack, name: nil, plugs: [], handlers: [] do
  @type name              :: atom
  @type plugs             :: [ Switchboard.Plug ]
  @type handlers          :: [ {atom, module} ]
  
  @moduledoc """
  Stacks
  
  A stack is a composition of plugs. Stack implements Switchboard.Plug, so you can invoke it just as you would a plug.
  
  ## Calling a stack
  
  
  """

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
  defp _call(result, _, stack), do: stack.handle(result)

  @doc """
  Handles return codes other than {:ok, _} and {:halt, _}
  """
  def handle({code, context}, stack) do
    handler = Keyword.get stack.handlers, code
    _handle code, context, handler
  end
  
  defp _handle(code, context, nil), do: {code, context}
  defp _handle(code, context, plug), do: plug.call context 


  @doc """
  Returns a new stack with a plug appended to the end of plugs.
  """
  def add_plug(plug, stack) do
    Switchboard.Stack.new name: stack.name, 
                          plugs: stack.plugs ++ [plug], 
                          handlers: stack.handlers
  end

  @doc """
  Add a new handler to the stack
  """
  def add_handler(handler, stack) do
    if handler.name == nil, do: raise "A stack must have a name to be a handler"
    Switchboard.Stack.new name: stack.name, 
                          plugs: stack.plugs, 
                          handlers: stack.handlers ++ [{binary_to_atom( handler.name ), handler}]
  end


  
  
end