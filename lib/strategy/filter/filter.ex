defmodule Switchboard.Strategy.Filter do
  @moduledoc """
  # Filter Strategy
  
  The filter strategy allows you to selectively call plugs based on the contents of your context. 
  This strategy lets you call a unique set of plugs (a filtered list) based on the attributes in your context. 
  These tools help you build such an API. 
  
  - ifplugs allow you to define a single filter, and apply that filter to one or more functions in your module.
  - a DSL allows you to easily define filters using a friendly API, based on attributes in your context. 
  - a dispatcher plug allows you to dispatch requests based on attributes in your context. 
  
  """
  
end