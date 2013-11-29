defmodule Switchboard.Plug do
  # func: nil, options: Keyword.new
  def new_from_anon(opt // Keyword.new) do
    f = opt[:func]
    &(f.(&1, opt[:options] || Keyword.new))
  end
  
  def new_from_mod_fun(opts // Keyword.new) do
    &mod_fun_plug(&1, opts)
  end
  
  def mod_fun_plug(context, opts) do
    apply opts[:module], 
          opts[:func],
          [context, opts[:options]]
  end
  
  def new_from_handler(opts // []) do
    &(__MODULE__.handle_stack_from_plug(&1, opts))
  end
  
  def handle_stack_from_plug(context, opts // Keyword.new) do
    stack = opts[:stack]
    handler_name = opts[:handler_name]
    if nil?( handler_name), do: no_handler
    Switchboard.Stack.handle(stack, handler_name, context)
  end

  defp no_handler, do: raise( "You attempted to call a handler plug with no handler")
  
  def new_from_module(opts), do: &invoke_from_module_plug(&1, opts)
  
  def invoke_from_module_plug(context, opts) do
    module = opts[:module]
    options = opts[:options] || Keyword.new
    Switchboard.Stack.call module.stack, context
  end
  
  
end