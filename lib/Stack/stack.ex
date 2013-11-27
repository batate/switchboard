defrecord Switchboard.Stack, name: nil, 
                             plugs: [], 
                             handlers: [], 
                             meta: Keyword.new do
  @type name              :: atom
  @type plugs             :: [ Switchboard.Plug ]
  @type handlers          :: Keyword.t
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

  def add_meta(key, value, stack), do: stack.update( meta: Keyword.put( stack.meta, key, value) ) 
  def metadata(key, stack), do: stack.meta[key]
  
  
  
  @doc """
  Add a new handler to the stack
  """
  def add_handler(handler, stack) do
    if handler.name == nil, do: raise "A stack must have a name to be a handler"
    stack.update handlers: (stack.handlers |> Keyword.put(binary_to_atom( handler.name ), handler))
  end
  
  def set_strategy(strategy, stack), do: stack.add_meta(:strategy, strategy)
  def strategy(stack), do: stack.metadata(:strategy) || Switchboard.Strategy.ForwardOther
  
  def call_while_ok({code, context}, stack), do: _call({code, context}, stack.plugs)
  def call_while_ok(context, stack), do: _call({:ok, context}, stack.plugs)
    

  defp _call({:ok, context}, [plug|tail]), do: _call(plug.call(context), tail) 
    
  defp _call({:ok, context}, []), do: {:ok, context}
  defp _call({:halt, context}, _), do: {:halt, context}
  defp _call(result, _), do: result
  
  @doc """
  Handles return codes other than {:ok, _} and {:halt, _}
  """
  def handle({:ok, context}), do: {:ok, context}
  def handle({:halt, context}), do: {:halt, context}
  def handle({code, context}, stack) do
    handler = stack.handlers[code]
    _handle code, context, handler
  end
  
  defp _handle(code, context, nil), do: {code, context}
  defp _handle(code, context, stack), do: stack.call context 
end