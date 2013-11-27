defrecord Switchboard.Plug.Fun, func: nil, module: nil, args: [] do
  @moduledoc """
  Fun Plugs
  
  This plug invokes a funcion on a module via apply
  
  """

  @doc """
  Call the function named by func on module
  """
  def call(context, plug) do
    apply( plug.module, 
           plug.func, 
           ([context] ++ plug.args))
  end
end
