defrecord Switchboard.Stack, name: nil, 
                             plugs: [], 
                             handlers: [], 
                             registered_plugs: [], 
                             strategy: Switchboard.Strategy.ForwardOther,
                             parent: nil,
                             meta: Keyword.new do
  @type name              :: atom
  @type plugs             :: [ Switchboard.Plug ]
  @type handlers          :: [ {atom, Switchboard.stack} ]
  @type strategy          :: atom
  @type parent            :: Switchboard.Stack
  @type meta              :: Keyword.t
  
  @moduledoc """
  Stacks
  
  A stack is a composition of plugs. Stack implements Switchboard.Plug, so you can invoke it just as you would a plug.
  
  ## Calling a stack

  This stack will be called with the associated strategy, or the default strategy. 
  """

  @doc """
  Call the stack with the associated strategy. 
  """
  def call({code, context}, stack), do: stack.strategy.call({code, context}, stack)
  def call(context, stack), do: call({:ok, context}, stack)

  @doc """
  Returns a new stack with a plug appended to the end of plugs.
  """
  def add_plug(plug, stack), do: stack.update( plugs: stack.plugs ++ [plug])

  
  
  @doc """
  Add a new handler to the stack
  """
  def add_handler(handler, stack) do
    if handler.name == nil, do: raise "A stack must have a name to be a handler"
    stack.update handlers: (stack.handlers |> Keyword.put(binary_to_atom( handler.name ), handler))
  end
  
  def set_strategy(strategy, stack), do: stack.update( strategy: strategy )
  
  def call_while_ok({code, context}, stack), do: _call({code, context}, stack.plugs)
  def call_while_ok(context, stack), do: _call({:ok, context}, stack.plugs)
    

  defp _call({:ok, context}, [plug|tail]), do: _call(plug.call(context), tail) 
    
  defp _call({:ok, context}, []), do: {:ok, context}
  defp _call({:halt, context}, _), do: {:halt, context}
  defp _call(result, _), do: result
  
  @doc """
  Handles return codes other than {:ok, _} and {:halt, _}
  """
  def handle(:ok, context, stack), do: {:ok, context}
  def handle(:halt, context, stack), do: {:halt, context}
  def handle(other, context, stack) do
    _handle other, context, stack.handler(other)
  end
  
  defp _handle(code, context, nil), do: raise("Unsupported handler: #{code}")
  defp _handle(code, context, stack), do: stack.call context
  
  def handler(key, nil), do: nil
  def handler(key, stack) do
    stack.handlers[key] || handler(key, stack.parent)
  end
  
end