# TODO This builder will need to work out how to get the parent in child stacks. 
# TODO handler plugs should be dynamic, by name. They take a stack; should pull the stack from the module at runtime. 
 
defmodule Switchboard.PlugBuilder do
  defmacro __using__(_) do
    quote do
      require Switchboard
      import Switchboard.PlugBuilder
      @plugs []
      @handlers []
      @parent nil
      @before_compile Switchboard.PlugBuilder
    end
  end
 
  defmacro plug(p, opts // []) do
    quote do
      @plugs [ [__MODULE__, unquote(p), unquote(opts)] |@plugs]
    end
  end
  
  defmacro __before_compile__(env) do
    plug_lists = Enum.reverse Module.get_attribute(env.module, :plugs)
    
    quote do
      def plugs do 
        Enum.map unquote( plug_lists ), &(Switchboard.Plug.Factory.build_plug/1)
      end
      
      def stack do
        Switchboard.Stack.Entity.new(plugs: plugs, module: __MODULE__)
      end
    end
  end
  
end