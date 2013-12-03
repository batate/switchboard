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
      @before_compile Switchboard.PlugBuilder
      
      # begin filter module attributes
      
      @filter_options [ action_function: &Switchboard.FilterBuilder.action_function/1, 
                        membership_function: &Switchboard.Scheme.Filter.member?/2 ]
      @dispatch_options [ action_function: &Switchboard.FilterBuilder.action_function/1, 
                          args_function: &Switchboard.FilterBuilder.args_function/1 ]
    end
  end
  
  @doc """
  Build the argument list for the dispatcher. 
  """
  def args_function(_), do: []
  
  @doc """
  Return the action from the context
  """
  def action_function(context), do: context.assigns[:action]
 
  defmacro filter(plug_spec, membership) do
    quote do
      opts = Module.get_attribute(__MODULE__, :filter_options)
      filter_spec = [ unquote(plug_spec), unquote(membership), opts]

      @plugs [Switchboard.PlugBuilder.custom_plug(__MODULE__, 
                                                  &Switchboard.FilterBuilder.build_filter/3, 
                                                  filter_spec)|@plugs]
    end
  end

  # Switchboard.Plug.new_from_mod_fun func: :dispatch, 
  #                         module: Switchboard.Plug.Dispatcher, 
  #                         options: [controller: opts[:controller], 
  #                                   action_fun: opts[:action_function], 
  #                                   args_fun: opts[:args_function] || (fn(_) -> [] end) ]

  # TODO make this implicit
  defmacro dispatch do
    quote do
      opts = Module.get_attribute(__MODULE__, :dispatch_options) |> Keyword.put( :controller, __MODULE__ )
      
      @plugs [Switchboard.PlugBuilder.custom_plug(__MODULE__, 
                                                  &Switchboard.FilterBuilder.build_dispatcher/3, 
                                                  [opts])|@plugs]
    end
  end
  
  def build_filter([filter_spec, membership, opts], module, parent_chain) do
    plug = Switchboard.Plug.Factory.build_plug(module, filter_spec, opts, parent_chain)
    Switchboard.Scheme.Filter.new_filter(plug, membership, opts)
  end
  
  def build_dispatcher([opts], _, _), do: Switchboard.Scheme.Filter.new_dispatcher(opts)
  
  
  defmacro filter_options(opts // []) do 
    quote do
      @filter_options unquote( opts )
    end
  end
  
  defmacro dispatch_options(opts // []) do 
    quote do
      @dispatch_options unquote( opts )
    end
  end
  
end