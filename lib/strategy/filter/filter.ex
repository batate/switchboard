defrecord Switchboard.Strategy.Filter, controller: nil, action_function: nil, args_function: nil do
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
  Test whether an action satisfies the criteria in membership. 
  
  - Membership is a tuple or nil. 
  - The tuple has a test, and a list of actions
  - The test can be :only or :except.
  
  """
  
  # imp call here:
  # call plugs
  # handle ensure 
  # handle plugs return code

  @doc """
  Create an IfPlug that works as a filter for this strategy. 
  The wrapped plug will fire if the action from the context satisfies member?(action, membership)
  
  
  """
  def new_filter(plug, membership, strategy) do
    Switchboard.Plug.IfPlug.new( plug, 
                                 strategy.action_function, 
                                 &Switchboard.Strategy.Filter.member?/2, 
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
  def new_dispatcher(strategy) do
    Switchboard.Plug.Fun.new func: :dispatch, 
                             module: Switchboard.Plug.Dispatcher, 
                             args: [strategy.controller, strategy.action_fun, strategy.args_fun || (fn -> [] end) ]
  end


  @doc """
  The DSL will build a stack, with a dispatcher at the end, and an :ensures handler. 
  
  The call function should traverse the stack using the basic rules for forward_other, 
  with one exception:
  
  the return code is processed after executing the ensures stack. 
  
  
  """
  def call(context, stack) do
    result = stack.call_while_ok(context)
    stack.handle {:ensure, context}, stack
    case result do
      { :ok, context } -> {:ok, context}
      { :halt, context } -> {:halt, context}
      {other, context} -> stack.handle {other, context}
    end
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