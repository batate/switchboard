defmodule Switchboard.Plug.Factory do
  @moduledoc """
  Factory
  
  Take the various shorthand formats and create a plug based on them. 
  """
  
  @doc """
  Create a plug
  
  This class translates all of the varous shorthand plug formats and creates formal records based on this specification. 
  
  The environment may have something to do with the plug that's created. 
  For example, an atom may be a function on a module, or a module, or a plug. 

  In the dsl, 
  stack |> 
  plug :authenticate |>
  plug :find_person |> 
  ...
  
  """
  def plug(stack, plug_spec) do
    new_plug = cond do
      is_atom plug_spec -> 
        create_from_atom plug_spec, stack
      is_tuple plug_spec ->
        create_from_tuple plug_spec
      is_function plug_spec ->
        Switchboard.Plug.Anon.new func: plug_spec
      true ->
        raise "Unsupported plug format"
    end
    
    stack.add_plug new_plug
  end
  
  @doc """
  Create from tuple
  
  Tuple plugs take the form {Module, :atom}
  
  where :atom is a function on a module
  """
  defp create_from_tuple({module, function}) do
    Switchboard.Plug.Fun.new func: function, module: module
  end

  
  @doc """
  Create from atom
  
  Atoms are handlers 
  """
  defp create_from_atom(plug_spec, stack) do
    cond do
      is_elixir_module(plug_spec) -> 
        Switchboard.Plug.Mod.new( module: plug_spec )
      true ->
        Switchboard.Plug.Handler.new handler_name: plug_spec, stack: stack
    end
  end
  
  defp is_elixir_module(module), do: match?("Elixir." <> _, atom_to_binary(module))
end