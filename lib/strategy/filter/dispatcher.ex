defmodule Switchboard.Plug.Dispatcher do
  def new(action_fun, controller, args_fun) do
    Switchboard.Plug.Fun.new func: :dispatch, module: __MODULE__, args: [controller, action_fun, args_fun]
  end
  
  def dispatch(context, controller, action_fun, args_fun) do
    action = context |> (action_fun.())
    args = context |> args_fun.()
    apply controller, 
          action, 
          ( [context] ++ (args || []) )
  end
  
end