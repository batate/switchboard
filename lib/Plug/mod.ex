defmodule Switchboard.Plug.Mod do
  # module: nil, options: Keyword.new
  
  def new(opts), do: &invoke_module_stack(&1, opts)
  
  def invoke_module_stack(context, opts) do
    module = opts[:module]
    options = opts[:options] || Keyword.new
    module.stack.call {:ok, context}
  end
  
  def call(context, plug), do: plug.(context)
end
