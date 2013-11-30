# TODO This builder will need to work out how to get the parent in child stacks. 
# TODO handler plugs should be dynamic, by name. They take a stack; should pull the stack from the module at runtime. 
defrecord Conn, result: 0
 
defmodule Switchboard.Builder.OnDo do
  defmacro __using__(_) do
    quote do
      require Switchboard
      import Switchboard.Builder.OnDo
      import Switchboard.Plug.Factory
      @plugs []
      @handlers []
      @parent nil
      @before_compile Switchboard.Builder.OnDo
    end
  end
 
  defmacro plug(plug, opts // []) do
    quote do
      # todo change stack to module on inbound plugs. invoking a handler will need to be by atom
      @plugs [build_plug( __MODULE__, unquote(plug), unquote(opts) )|@plugs]
    end
  end
 
  # defmacro __before_compile__(env) do
  #   [h|t] = Module.get_attribute(env.module, :plugs) 
  #   body  = Enum.reduce t, plug_to_call(h), &merge_plugs/2
  #   quote do
  #     def call(conn, _opts), do: unquote(body)
  #   end
  # end
 
end