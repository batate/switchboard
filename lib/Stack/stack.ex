defrecord Switchboard.Stack, name: nil, 
                             plugs: [], 
                             handlers: [], 
                             meta: [] do
  @type name              :: atom
  @type plugs             :: [ Switchboard.Plug ]
  @type handlers          :: Keyword.t
  @type strategy          :: Switchboard.Strategy
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
  def call(context, stack), do: stack.strategy.call(context, stack)

  @doc """
  Call the stack with the associated strategy. 
  """
  def handle(context, stack), do: stack.strategy.handle(context, stack)

  @doc """
  Returns a new stack with a plug appended to the end of plugs.
  """
  def add_plug(plug, stack) do
    Switchboard.Stack.new name: stack.name, 
                          plugs: stack.plugs ++ [plug], 
                          handlers: stack.handlers, 
                          strategy: stack.strategy, 
                          meta: stack.meta
  end
  
  
  @doc """
  Add a new handler to the stack
  """
  def add_handler(handler, stack) do
    if handler.name == nil, do: raise "A stack must have a name to be a handler"
    Switchboard.Stack.new name: stack.name, 
                          plugs: stack.plugs, 
                          handlers: (stack.handlers |> Keyword.put(binary_to_atom( handler.name ), handler)), 
                          strategy: stack.strategy, 
                          meta: stack.meta
                          
  end
  
  def set_strategy(strategy, stack), do: stack.add_meta(:strategy, strategy)
  def strategy(stack), do: stack.metadata(:strategy) || Switchboard.Strategy.ForwardOther
  
  def add_meta(key, value, stack) do
    Switchboard.Stack.new name: stack.name, 
                          plugs: stack.plugs, 
                          handlers: stack.handlers, 
                          strategy: stack.strategy, 
                          meta: (stack.meta |> Keyword.put(key, value) )
  end
  
  def metadata(key, stack), do: Keyword.get(stack.meta, key)
end