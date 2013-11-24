defmodule Switchboard.Strategy.Filter do
  @moduledoc """
  # Filter and Dispatch Strategy
  
  The filter strategy allows you to selectively call plugs based on the contents of your context. 
  This strategy lets you call a unique set of plugs (a filtered list) based on the attributes in your context. 
  These tools help you build such an API. 
  
  - ifplugs allow you to define a single filter, and apply that filter to one or more functions in your module.
  - a DSL allows you to easily define filters using a friendly API, based on attributes in your context. 
  - a dispatcher plug allows you to dispatch requests based on attributes in your context. 
  
  """
  
  @doc """
  Test whether an action satisfies the criteria in membership. 
  
  - Membership is a tuple or nil. 
  - The tuple has a test, and a list of actions
  - The test can be :only or :except.
  
  """
  def member?(action, membership // []), do: _member?( action, membership )
  
  defp _member?( action, nil ), do: true
  defp _member?( action, { :only, onlys } ), do: (action in onlys)
  defp _member?( action, { :except, excepts} ), do: (not action in excepts)
  defp _member?(_, _), do: raise "unsupported filter keyword"
  
end