defmodule Switchboard.Strategy.ForwardOther do
  
  @moduledoc """
  Halt if any plug returns anything other than :ok
  :halt will halt the stack and return :halt
  :other will forward to the next object in the stack
  """
  
  @doc """
  Call a single plug, ignoring what happens after :other
  """
  def call_plug(plug, {:ok, context}), do: plug.(context)
  def call_plug(plug, response), do: response
  
  def after_plugs(stack, other, context), do: Switchboard.Stack.handle( stack, other, context )
  
end