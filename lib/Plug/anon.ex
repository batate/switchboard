defrecord Switchboard.Plug.Anon, func: nil, options: Keyword.new do
  def call(context, plug), do: plug.func.(context, plug.options)
end
