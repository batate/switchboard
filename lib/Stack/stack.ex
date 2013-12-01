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
  def handler(stack, key), do: (stack.handlers[key] || handler(stack.parent, key))
  
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