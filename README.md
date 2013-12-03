# Switchboard

Welcome to Switchboard, a framework for composing Elixir applications in a uniform way. Any two Elixir functions that conform to the Plug API can be connected through Switchboard. 

## Plugs

The common API for functions in Switchboard is the plug. A plug is:

- an Elixir function
- that takes two arguments: a context and a keyword dictionary of options
- and returns that context, transformed, and a return code.

This is a simple example of a plug which uses a number as a context, and defaults options to an empty list:

```elixir
def inc(context, _ // []), do: context + 1
def dec(context, _ // []), do: context - 1
```

Since plugs have the same API, you can compose with them. In theory, we're doing something like this:

```elixir
comtext |> inc |> dec
```

But the chaining of plugs often needs to halt in the middle for many reasons. 

- A web application may need to halt a chain to show an authorization or not-found page. 
- Any application may want to handle exceptions by catching the exception and logging the error and notifying the user, or admins. 

In practice, we may want to compose different stacks of plugs in different ways. 

Enter Switchboard. 






