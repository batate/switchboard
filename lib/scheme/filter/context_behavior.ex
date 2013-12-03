defmodule Switchboard.Scheme.Filter.Behavior do
  @moduledoc """
  The default behaviors to get action and params from the connection
  """
  @doc """
  Default action for getting an action out of a connection record. 
  """
  def action(context), do: context.assigns[:action]

  @doc """
  Sometimes, it's nice to build a function to build an argument list for 
  """
  def args(context), do: [context, context.assigns[:current_user]]
end
