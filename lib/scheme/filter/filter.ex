defrecord Switchboard.Scheme.Filter, 
  controller: nil, 
  action_function: nil, 
  args_function: nil do
  @moduledoc """
  # Filter and Dispatch Strategy
  
  
  The filter strategy allows you to selectively call plugs based on the contents of your context. 
  This strategy lets you call a unique set of plugs (a filtered list) based on the attributes in your context. 
  These tools help you build such an API. 
  
  - ifplugs allow you to define a single filter, and apply that filter to one or more functions in your module.
  - a DSL allows you to easily define filters using a friendly API, based on attributes in your context. 
  - a dispatcher plug allows you to dispatch requests based on attributes in your context. 
  
  For examplle, consider a controller module:
  
  defmodule PeopleController do
    ...
    
    def show(context), do: conn.render
    def index(context), do: conn.render
    def delete(context) do
      Repo.delete context.assigns[:person]
      conn.redirect_to("people/index")
    end
    ...
  end
  
  You might want to selectively add plugs that set items in your context, like this:

  filter :cache_page, except: [:delete]
  filter :lookup_person, except: [:index]
  filter :lookup_peopple, only: [:index]
  ensures :sweep_cache, only: [:delete]

  This strategy requires:
  - plugs that conditionally fire before the action, called filters
  - a plug that selects the desired filter, called a dispatcher plug
  
  To implement these filter plugs, the strategy will need:
  
  - a function to get the action from your connection. 
  - the controller for your application
  - an optional function to return the arguments that you would like to pass to your controller. 
  """

  @doc """
  Create an IfPlug that works as a filter for this strategy. 
  The wrapped plug will fire if the action from the context satisfies member?(action, membership)
  
  
  """
  def new_filter(plug_spec, membership, options) do
    Switchboard.Plug.IfPlug.new( plug_spec, 
                                 options[:action_function], 
                                 &Switchboard.Scheme.Filter.member?/2, 
                                 membership )
  end
  
  @doc """
  Create a new dispatcher plug for this strategy. The dispatcher plug will:

  - on strategy.controller
  - call a function identified by the action returned by context |> strategy.action_fun
  - passing the context plus attributes returned by context |> args_fun
  
  For example, it may be useful to always have the current user passed to a person_controller action, 
  as well as :person or :people for functions requiring them. 
  
  def args(context) do
    case context.api_class of
      :member -> [context.assigns[:current_user], context.assigns[:person]]
      :collection -> [context.assigns[:current_user], context.assigns[:people]]
      _ -> [context.assigns[:current_user]]
    end
  end
  
  The wrapped plug will fire if the action from the context satisfies member?(action, membership)
  
  
  """
  def new_dispatcher(opts) do
    Switchboard.Plug.new_from_mod_fun func: :dispatch, 
                             module: Switchboard.Plug.Dispatcher, 
                             options: [controller: opts[:controller], 
                                       action_fun: opts[:action_function], 
                                       args_fun: opts[:args_function] || (fn(_) -> [] end) ]
  end

  @doc """
  Test whether an action satisfies the criteria in membership. 
  
  - Membership is a tuple or nil. 
  - The tuple has a test, and a list of actions
  - The test can be :only or :except.
  
  """
  def member?(action, membership), do: _member?( action, membership )

  defp _member?( action, nil ), do: true
  defp _member?( action, { :only, onlys } ), do: (action in onlys)
  defp _member?( action, { :except, excepts} ), do: (not action in excepts)
  defp _member?(_, _), do: raise "unsupported filter keyword"
  
end

