defmodule Switchboard.Strategy.ForwardOther do
  
  @doc """
  Calls this stack. 
  
  Both forms of this call normalize to 
  call {code, context}, stack
  
  Call all of the plugs in this stack, in order, until the code is something other than :ok. 
  All codes other than :ok will be handled by the stack handler 
  
  """
  def call({code, context}, stack) do 
    {code, context} = stack.call_while_ok({code, context}) 
    stack.handle code, context
  end
  
end