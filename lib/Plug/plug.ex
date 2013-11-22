defprotocol Switchboard.Plug do
  @doc "Calls the function wrapped by a plug"
    def call(context)
end