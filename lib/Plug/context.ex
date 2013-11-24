defrecord Context, assigns: Keyword.new do
  def assign(key, value, context), do: Context.new assigns: Keyword.put(context.assigns, key, value)
  def get(key, context), do: Keyword.get( context.assigns, key )
end
