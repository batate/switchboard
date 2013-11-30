defmodule Switchboard.Strategy.ForwardOther do
  
  @moduledoc """
  Halt if any plug returns anything other than :ok
  :halt will halt the stack and return :halt
  :other will forward to the next object in the stack
  """
  
  @doc """
  Call a single plug, ignoring what happens after :other
  
  Called by reduce from stack in call_plugs
  """
  def call_plug(plug, {:ok, context}), do: plug.(context)
  def call_plug(plug, response), do: response
  
  
  @doc """
  Invoked from stack after full plug chain is invoked
  
  This strategy halts on :halt, continues on :ok, and 
  halts on :other after invoking handler for :other
  """
  def after_plugs(stack, :ok, context), do: {:ok, context} 
  def after_plugs(stack, other, context) do 
    {_, context} = Switchboard.Stack.handle( stack, other, context )
    {:halt, context}
  end
  
end