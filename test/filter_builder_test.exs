defmodule FilterBuilderTest do
  use ExUnit.Case
  import Should
  
  defmodule Filters do
    use Switchboard.FilterBuilder
    
    filter :mark, {:only, [:show]}
    dispatch
    
    def show(context, _), do: {:ok, context.assign(:show, "invoked")}
    def mark(context, _), do: {:ok, context.assign(:marked, "true")}
    
  end
  
  should "compile", do: assert true
  
  should "render plugs" do
    plugs = Filters.plugs([])
  end
  
  should "execute plugs" do
    context = Switchboard.Context.new( assigns: [action: :show])
    {_, context} = Switchboard.Stack.call Filters.stack, context
    assert Switchboard.Context.get( :marked, context ) == "true"
    assert Switchboard.Context.get( :show, context ) == "invoked"
  end

end