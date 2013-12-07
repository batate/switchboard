# Switchboard

Welcome to Switchboard, a thought experiment on what it means to separate these concerns: 

- function composition
- strategy for composition
- rigid interface (f(context, options) -> {:code, transformed_context}
- dsls for doing the above

In the end, I want to determine whether it makes sense to provide an abstraction on top of base Elixir concepts in a simple, performant, flexible way. 

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

Enter Switchboard

You might not see the need for Switchboard for a simple app. I agree with you. When Elixir is enough, use it. In truth, most complex applications need to do some common plumbing. Switchboard:

## Common DSLs

- Provides simple DSLs that solve the types of problems you see over and over

```elixir
defmodule Request do
  ...
  plug ParseParams
  plug EnforseSSL
  ...
end

defmodule Notify do
  ...
  plug :notify_admins, ["admin1@example.com", ...]
  plug :log_error, [System.Logger.Error]
  
  def notify_admins(context, []), do: something
  def notify_admins(context, []), do: something_else
end
```

Switchboard makes it easy to compose groups of plugs, called stacks:

```elixir
defmodule Application do
  ...
  plug Request
  plug Router
  plug Renderer

  on :authenticate, Vendor.Authenticate
  on :error, Notify
end
```

Switchboard supports multiple DSLs for different goals:

```elixir
defmodule OldSchoolController do
  ...
  filter :find_student, only: [members]
  filter :find_students, only: [connection]
  filter :authentication_required # defined in an on-block on a common parent
  dispatch
  ensure :clear_cache, only: [:delete, :update, :create]
  
  def show(context), do: ...
end
```

Switchboard also supports different strategies. This strategy will halt as soon as a :halt return code is encountered. 

```elixir
defmodule SomethingDangerous do
  strategy Switchboard.Strategy.Halt
  plug :something_safe
  plug :something_dangerous
end
```

In short, Switchboard allows you to write functions and then script them to glue them together using a higher level DSL.

## Core questions

- Will this framework hide important details, or can it be relatively clear?
- Is it possible to split the abstractions at the key places, without unnecessary coupling?
- In short, does the framework provide enough value over native elixir to be worth what is lost?





