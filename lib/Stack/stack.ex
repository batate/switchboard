defrecord Switchboard.Stack, name: nil, plugs: [], handlers: [], strategy: nil do
  @type name              :: atom
  @type plugs             :: [ Switchboard.Plug ]
  @type handlers          :: [ {atom, module} ]
  @type strategy          :: Switchboard.Strategy
  
  @moduledoc """
  Stacks
  
  A stack is a composition of plugs. Stack implements Switchboard.Plug, so you can invoke it just as you would a plug.
  
  ## Calling a stack

  This stack will be called with the associated strategy, or the default strategy. 
  """

  @doc """
  Call the stack with the associated strategy. 
  """
  def call(context, stack), do: stack.strategy_or_default.call(context, stack)

  @doc """
  Call the stack with the associated strategy. 
  """
  def handle(context, stack), do: stack.strategy_or_default.handle(context, stack)



  def strategy_or_default(stack), do: stack.strategy || Switchboard.Strategy.ForwardOther
  

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