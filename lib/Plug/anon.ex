defmodule Switchboard.Plug.Anon do
  # func: nil, options: Keyword.new
  def new(opt // Keyword.new) do
    f = opt[:func]
    &(f.(&1, opt[:options] || Keyword.new))
  end
  
  def call(context, plug), do: plug.(context, plug.options)
end
