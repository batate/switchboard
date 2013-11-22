defrecord Switchboard.Stack, name: nil, plugs: [] do
  def call(context, stack), 
    do: _call({:ok, context}, stack.plugs)

  defp _call({:ok, context}, [plug|tail]), 
    do: _call(plug.call(context), tail) 
    
  defp _call({:ok, context}, []), 
    do: ({:ok, context})
    
  defp _call({:halt, context}, _), 
    do: ({:halt, context})
  
  def add(new_plug, stack), 
    do: Switchboard.Stack.new name: stack.name, plugs: stack.plugs ++ [new_plug]
  
end