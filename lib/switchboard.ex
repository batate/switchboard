defmodule Switchboard do
  @moduledoc """
  # Switchbord
  
  Switchboard is a composition strategy for composing functions. 
  Functions are wrapped in records called plugs, composed in compositions called stacks, 
  and compositions are executed using strategies. 
  Several strategies are provided that help compose functions in interesting ways.
  Domain specific languages are provided that help the functions compose neatly. 
  
  ## Plugs
  
  Plugs are wrappers around executable elements. These functions:
  
  - Support a common protocol. Specifically, you can execute them, passing a payload, called a context.
  - Transform the context in a series of steps.  
  - Support the same types of return code. Specifically, they return {code, context}
    
  ## Stacks
  
  A stack is a list of plugs. The stacks
  
  - Are plugs. You can execute them, by wrapping them in a plug. 
  - Support strategies. The strategies define how a plug list is interpreted, and when or how to interrupt the execution of a stack. 
  - can call plugs which wrap other stacks, so you can decompose problems easily. 
  
  ## Strategies
  
  A strategy defines
  
  - how to execute a plug stack
  - how to halt the execution of a stack
  - what to do when the stack terminates
  
  """
end
