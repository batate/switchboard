defrecord Switchboard.Stack.Entity, 
  name: nil, 
  plugs: [], 
  handlers: [], 
  strategy: Switchboard.Strategy.ForwardOther,
  parent: nil,
  module: nil, 
  meta: Keyword.new do
    @type name              :: atom
    @type plugs             :: [ Switchboard.Plug ]
    @type handlers          :: [ {atom, Switchboard.stack} ]
    @type strategy          :: atom
    @type parent            :: Switchboard.Stack
    @type module            :: atom
    @type meta              :: Keyword.t
end