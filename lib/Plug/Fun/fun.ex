defrecord Switchboard.Plug.Fun, function_name: nil, module: nil, args: [] do
  def call(context, plug) do
    apply( plug.module, 
           plug.function_name, 
           ([context] ++ plug.args))
  end
end
