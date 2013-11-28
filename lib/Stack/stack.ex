defrecord Switchboard.Stack, name: nil, 
                             plugs: [], 
                             handlers: [], 
                             strategy: Switchboard.Strategy.ForwardOther,
                             parent: nil,
                             module: nil, 
                             meta: Keyword.new do
  @type name              :: atom
  @type plugs             :: [ Switchboard.Plug ]
  @type handlers          :: [ {atom, Switchboard.stack} ]
  @type strategy          :: atom
  @type parent            :: Switchboard.Stack
  @type module            :: atom
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
  def call({:ok, context}, stack), do: stack.strategy.call({:ok, context}, stack)
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
  
  def call_while_ok({code, context}, stack), do: _call_while_ok({code, context}, stack.plugs)
    
  defp _call_while_ok({:ok, context}, []), do: {:ok, context}
  defp _call_while_ok({:ok, context}, [plug|tail]), do: _call_while_ok(plug.(context), tail) 
  defp _call_while_ok({code, context}, _), do: {code, context}
  
  @doc """
  process a handle with the given code. 
  
  - :halt and :ok will just pass through, 
  - :other will try to look at the stack's module for a function named other/2 and invoke it
  - failing that, will try to invoke the handler on the stack with that name
  - failing that, will move to the parent and go through the same process
  - if no handler is found on the parents, will raise an exception
  
  
  """
  def handle(:ok, context, stack), do: {:ok, context}
  def handle(:halt, context, stack), do: {:halt, context}
  def handle(nil, context, stack), do: (raise "Called handle without a name")
  def handle(other, context, stack) do
    cond do
      stack.supports_function(other) -> 
        apply(stack.module, other, ([context, []]))
      true ->
        _handle other, context, stack.handler(other)
    end
  end
  defp _handle(code, context, nil), do: (raise "Unsupported handler: #{code}")
  defp _handle(code, context, stack), do: stack.call context
  
  def handler(key, nil), do: nil
  def handler(key, stack) do
    stack.handlers[key] || handler(key, stack.parent)
  end
  
  def ensure(context, stack) do
    cond do
      stack.supports_function(:ensure) -> 
        stack.fire_ensure(context)
      stack.handlers[:ensure] != nil ->
        stack.handlers[:ensure].call {:ok, context}
      true ->
        {:ok, context}
    end
  end
  
  def fire_ensure(context, stack) do
    apply(stack.module, :ensure, ([context, []]))
  end
  
  def supports_function(other, stack) do 
    ((stack.module != nil) and function_exported?(stack.module, other, 2))
  end
  
  
end