defrecord Switchboard.Plug.Anon, func: nil do
  def call(context, plug), do: plug.func.(context)
end
