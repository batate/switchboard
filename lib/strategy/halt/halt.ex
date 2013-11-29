defrecord Switchboard.Strategy.Halt, module: nil do
  @moduledoc """
  Halt if any plug returns a halt result
  otherwise, call the next plug in the stack
  """
  
  @doc """
  Call a single plug, ignoring plugs after :halt
  """
  def call_plug(plug, {:halt, context}), do: {:halt, context}
  def call_plug(plug, {other, context}), do: plug.(context)

  def after_plugs(_, code, context), do: {code, context}
end