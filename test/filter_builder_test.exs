defmodule FilterBuilderTest do
  use ExUnit.Case
  import Should
  
  defmodule Filters do
    use Switchboard.FilterBuilder
    
    filter :mark, {:only, [:show]}
    dispatch
    
    def show(context), do: {:ok, context.assign(:show, "invoked")}
    
  end
  
  should "compile", do: assert true
  
  should "render plugs" do
    plugs = Filters.plugs([])
    IO.puts "Plugs: #{inspect plugs}"
  end
  
  should "execute plugs" do
    Filters.stack
  end

end