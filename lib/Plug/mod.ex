defrecord Switchboard.Plug.Mod, module: nil, options: Keyword.new do
  def call(context, plug), do: plug.module.stack.call {:ok, context}
  
  def name(plug) do 
    plug.module |> 
    Kernel.to_string |> 
    String.split( ".") |>
    Enum.reverse |> 
    Enum.first |> 
    Mix.Utils.underscore
  end
end
