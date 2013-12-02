defmodule Switchboard.Stack do
  
  @moduledoc """
  Stacks
  
  A stack is a composition of plugs. This module has behaviors; 
  the entity with attributes is in Stack.Entity.
  Stack implements Switchboard.Plug, so you can invoke it just as you would a plug.
  
  ## Calling a stack

  This stack will be called with the associated strategy, or the default strategy. 
  """

  @doc """
  Call the stack with the associated strategy. 
  """
  def call(stack, context, code // :ok) do 
    {code, context} = call_plugs(stack, code, context) 
    {code, context} = stack.strategy.after_plugs(stack, code, context)
    {_, context} = ensure stack, context
    
    {code, context}
  end

  defp call_plugs(stack, code, context) do 
    Enum.reduce( stack.plugs, {code, context}, &(stack.strategy.call_plug(&1, &2)))
  end

  @doc """
  Conveninece method for DSL to buid a handler
  """
  def build_handler([name, module]), do: build_handler(name, module)
  def build_handler(name, module) do
    strategy = case function_exported?(module, :strategy, 0) do
      true -> module.strategy
      false -> Switchboard.Strategy.ForwardOther
    end 
    
    if !module, do: raise( "The module for a handler can't be nil" )
    if !name , do: raise( "The name for a handler can't be nil" )
    if !function_exported?(module, :plugs, 0 ), do: raise( "All handlers must support plugs/0" )
    if !function_exported?(module, :stack, 0 ), do: raise( "All handlers must support stack/0" )
    h = Switchboard.Stack.Entity.new name: name, plugs: module.plugs, module: module, strategy: strategy
    {name, h}
  end
  
  @doc """
  Switchboard maintains a parent chain as plugs are built, so that 
  all handlers from your parent chain can be reached. 
  
  - :halt and :ok will just pass through, 
  - :other will try to look at the stack's module for a function named other/2 and invoke it
  - failing that, will try to invoke the handler on the stack with that name
  - failing that, will move to the parent and go through the same process
  - if no handler is found on the parents, will raise an exception
  
  """
  def parent(nil), do: nil
  def parent(stack) do
    [parent_module|parent_chain] = stack.parent_chain
    parent_module.stack(parent_chain)
  end
  
  
  @doc """
  process a handle with the given code. 
  
  - :halt and :ok will just pass through, 
  - :other will try to look at the stack's module for a function named other/2 and invoke it
  - failing that, will try to invoke the handler on the stack with that name
  - failing that, will move to the parent and go through the same process
  - if no handler is found on the parents, will raise an exception
  
  """
  def handle(stack, :ok, context), do: {:ok, context}
  def handle(stack, :halt, context), do: {:halt, context}
  def handle(stack, nil, context), do: (raise "Called handle without a name")
  def handle(stack, other, context) do
    cond do
      supports_function(stack, other) -> 
        apply(stack.module, other, ([context, []]))
      true ->
        _handle other, context, handler(stack, other)
    end
  end

  # no more parents, so the handler is unsupported
  defp _handle(code, context, nil), do: (raise "Unsupported handler: #{code}")
  defp _handle(code, context, stack), do: call( stack, context)
  
  def handler(nil, key), do: nil
  def handler(stack, key), do: (stack.handlers[key] || handler(parent( stack ), key))
  
  def ensure(stack, context), do: handle_if(stack, context, :ensure)
  
  @doc """
  Handle this code if a function of a stack exists on this level. 
  
  Useful for implementing features like 
  """
  def handle_if(stack, context, code) do
    handler_stack = stack.handlers[code] 
    cond do
      supports_function(stack, code) -> 
        {code, context} = call_handler_function(stack, context)
      handler_stack != nil ->
        call handler_stack, context
      true ->
        {:ok, context}
    end
  end
  
  def call_handler_function(stack, context) do
    apply(stack.module, :ensure, ([context, []]))
  end
  
  def supports_function(stack, other) do 
    ((stack.module != nil) and function_exported?(stack.module, other, 2))
  end
  
  
end