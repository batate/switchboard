defmodule Switchboard.Plug.Handler do 
  def new(opts // []) do
    &(__MODULE__.invoke_hanlder(&1, opts))
  end
  
  def call(context, plug), do: plug.(context)
  
  def invoke_hanlder(context, opts // Keyword.new) do
    stack = opts[:stack]
    handler_name = opts[:handler_name]
    if nil?( handler_name), do: no_handler
    stack.handle(handler_name, context)
  end

  def no_handler, do: raise( "You attempted to call a handler plug with no handler")

end
