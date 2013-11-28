defmodule Switchboard.Plug.Fun do
  @moduledoc """
  Fun Plugs
  
  This plug invokes a funcion on a module via apply
  
  func must have the signature 
  
  f(context, y // Keyword.new ) -> {:code, context}  
  """

  @doc """
  Call the function named by func on module
  """
  def new(opts // Keyword.new) do
    &apply_function(&1, opts)
  end
  
  def apply_function(context, opts) do
    apply opts[:module], 
          opts[:func],
          [context, opts[:options]]
  end
  
  def call(context, plug) do
    plug.(context)
  end
end
