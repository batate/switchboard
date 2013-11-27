

defrecord Switchboard.Plug.Handler, 
    stack: Switchboard.Plug.Handler.Default, 
    handler_name: nil, args: [] do
  def call(context, plug), do: plug.stack.handle(plug.handler_name, context)
end

defmodule Switchboard.Plug.Handler.Default do
  def call(_, _), do: raise "You attempted to call a handler plug with no handler"
end
