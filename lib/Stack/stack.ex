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
    Enum.reduce( stack.plugs, 
                 {code, context}, 
                 &(stack.strategy.call_plug(&1, &2)))
  end

  def call_plug(plug, {:ok, context}), do: plug.(context)
  def call_plug(plug, {other, context}), do: {other, context}
  

  
  @doc """
  Returns a new stack with a plug appended to the end of plugs.
  """
  def add_plug(stack, plug), do: stack.update( plugs: stack.plugs ++ [plug])

  
  
  @doc """
  Add a new handler to the stack
  """
  def add_handler(stack, handler) do
    if handler.name == nil, do: raise "A stack must have a name to be a handler"
    stack.update handlers: (stack.handlers |> Keyword.put(binary_to_atom( handler.name ), handler))
  end
  
  def set_strategy(stack, strategy), do: stack.update( strategy: strategy )
  
  
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
  def handler(stack, key) do
    stack.handlers[key] || handler(stack.parent, key)
  end
  
  def ensure(stack, context) do
    ensure_stack = stack.handlers[:ensure] 
    cond do
      supports_function(stack, :ensure) -> 
        {code, context} = call_ensure_function(stack, context)
      ensure_stack != nil ->
        call ensure_stack, context
      true ->
        {:ok, context}
    end
  end
  
  def call_ensure_function(stack, context) do
    apply(stack.module, :ensure, ([context, []]))
  end
  
  def supports_function(stack, other) do 
    ((stack.module != nil) and function_exported?(stack.module, other, 2))
  end
  
  
end