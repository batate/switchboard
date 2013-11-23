defprotocol Switchboard.Strategy do
  @doc "Call a stack with a given context"
    def call(stack, context)
end