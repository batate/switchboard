defrecord Switchboard.Plug.Mod, module: nil, args: [] do
  def call(context, plug), do: plug.module.stack.call context
end
