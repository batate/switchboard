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

In short, Switchboard allows you to compose plugs in the right language for the job, and then roll up your applications with common code and DSLs that handle the integration glue for you.  Write your functions in Elixir. Test them as units. Build them to conform to a common specification. Then wire them up using a DSL. 

It just makes sense. 






