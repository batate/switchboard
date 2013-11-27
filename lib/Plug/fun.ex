defrecord Switchboard.Plug.Fun, func: nil, module: nil, args: [] do
  def call(context, plug) do
    apply( plug.module, 
           plug.func, 
           ([context] ++ plug.args))
  end
end
