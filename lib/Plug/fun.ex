defrecord Switchboard.Plug.Fun, func: nil, module: nil, options: Keyword.new do
  @moduledoc """
  Fun Plugs
  
  This plug invokes a funcion on a module via apply
  
  func must have the signature 
  
  f(context, y // Keyword.new ) -> {:code, context}  
  """

  @doc """
  Call the function named by func on module
  """
  def call(context, plug) do
    apply plug.module, 
          plug.func, 
          [context, plug.options]
  end
end
