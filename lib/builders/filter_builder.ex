defmodule Switchboard.FilterBuilder do
  defmacro __using__(_) do
    quote do
      require Switchboard
      import Switchboard.PlugBuilder
      import Switchboard.FilterBuilder
      
      # todo dry this uo
      @plugs []
      @strategy Switchboard.Strategy.ForwardOther
      @handlers []
      @scheme Switchboard.Scheme.Filter.Entity.new
      @before_compile Switchboard.PlugBuilder
      
      # begin filter module attributes
      
      @filter_options [ action_function: &Switchboard.FilterBuilder.action_function/2, 
                        membership_function: &Switchboard.Scheme.Filter.member?/2 ]
    end
  end
  
  def action_function(context), do: context.assigns[:action]
  
 
  defmacro filter(plug_spec, action, membership) do
    
    opts = Module.get_attribute(__MODULE__, :filter_options)
    quote do
      @plugs [ :custom, FilterBuilder, [ module: __MODULE__, 
                                         plug_spec: unquote(plug_spec), 
                                         action: unquote(action),
                                         membership: unquote(membership), 
                                         options: unquote(opts)] |@plugs]
    end
  end
  
  defmacro filter_options(opts // []) do 
    quote do
      @filter_options unquote( opts )
    end
  end
  
end