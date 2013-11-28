defmodule Switchboard.Plug.Dispatcher do
  def new(action_fun, controller, args_fun) do
    Switchboard.Plug.Fun.new func: :dispatch, module: __MODULE__, 
                             options: [controller: controller, action_fun: action_fun, args_fun: args_fun]
  end
  
  def dispatch(context, options) do
    action = (options[:action_fun].(context))
    args = options[:args_fun].(context)
    apply options[:controller], action, [context, args] 
  end
  
end