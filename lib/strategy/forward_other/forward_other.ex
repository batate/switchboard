defmodule Switchboard.Strategy.ForwardOther do
  
  @doc """
  Calls this stack. 
  
  Call all of the plugs in this stack, in order, until the code is something other than :ok. 
  All codes other than :ok will be handled by the stack handler 
  
  """
  def call(code, context, stack) do
     
    {code, context} = Switchboard.Stack.call_while_ok(stack, {code, context}) 
    result = Switchboard.Stack.handle stack, code, context
    result
  end
  
end