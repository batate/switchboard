defmodule Switchboard.Plug.Factory do
  @moduledoc """
  Factory
  
  Take the various shorthand formats and create a plug based on them. 
  """
  
  @doc """
  Create a plug

  Tuple plugs take the form {Module, :atom}
  where :atom is a function on a module
  
  Atoms are handlers 
  
  This class translates all of the varous shorthand plug formats and creates formal records based on this specification. 
  
  The environment may have something to do with the plug that's created. 
  For example, an atom may be a function on a module, or a module, or a plug. 

  In the dsl, 
  stack |> 
  plug :authenticate |>
  plug :find_person |> 
  ...
  
  """
  def build_plug([module, plug_spec, opts], parent // nil), do: build_plug(module, plug_spec, opts, parent)
  def build_plug(module, plug_spec, opts, parent // nil) do
    cond do
      is_atom plug_spec -> 
        create_from_atom plug_spec, module, opts, parent
      is_tuple plug_spec ->
        create_from_tuple plug_spec, opts
      is_function plug_spec ->
        Switchboard.Plug.new_from_anon func: plug_spec, options: opts
      true ->
        raise "Unsupported plug format"
    end
  end
  
  defp create_from_tuple({module, function}, opts) do
    Switchboard.Plug.new_from_mod_fun func: function, module: module
  end

  # set the parent in the new stack for modules (to maintain the context)
  defp create_from_atom(plug_spec, module, opts, parent) do
    case is_elixir_module(plug_spec) do
      true -> Switchboard.Plug.new_from_module module: plug_spec, options: opts, parent: parent 
      false -> Switchboard.Plug.new_from_handler handler_name: plug_spec, module: module, parent: parent
    end
  end
  
  defp is_elixir_module(module), do: match?("Elixir." <> _, atom_to_binary(module))
end