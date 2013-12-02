# Replace handler with name/value pairs. That's all that's needed 
# handler chain gets rolled up with build step. 
# Parents can fall out. Ensure chain can be called after initial stack. 
# Build-chain:
#   Build out plugs as you go
#   Replace plug macro with stack macro
#   Each build traverses its plug chain, instantiating its plugs
# 
# TODO This 
 
defmodule Switchboard.PlugBuilder do
  defmacro __using__(_) do
    quote do
      require Switchboard
      import Switchboard.PlugBuilder
      @plugs []
      @strategy Switchboard.Strategy.ForwardOther
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
  
  defmacro on(name, module) do
    quote do
      @handlers [ [unquote(name), unquote(module)] | @handlers ]
    end
  end

  defmacro strategy(s) do
    quote do: @strategy unquote(s)
  end
  
  defmacro __before_compile__(env) do
    plug_list = Enum.reverse Module.get_attribute(env.module, :plugs)
    handler_list = Module.get_attribute(env.module, :handlers)
    strat = Module.get_attribute(env.module, :strategy)
    quote do
      def plugs(parent // nil) do 
        Enum.map unquote( plug_list ), &(Switchboard.Plug.Factory.build_plug(&1, parent))
      end
      
      def stack(parent // nil) do
        Switchboard.Stack.Entity.new(
          plugs: plugs(parent), 
          module: __MODULE__, 
          handlers: handlers, 
          strategy: unquote(strat), 
          parent: parent )
      end
      
      def handlers do
        Enum.map unquote( handler_list ), &(Switchboard.Stack.build_handler/1)
      end
    end
  end
  
end