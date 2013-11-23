defprotocol Switchboard.Strategy do
  @doc "Call a stack with a given context"
    def call(stack, context)
    
  @doc "Handle non-OK return codes"
    def handle(code, context)
end