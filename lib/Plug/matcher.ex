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

  
  """
  def plug(plug_spec, env // Switchboard.Env.new) do
    cond do
      is_atom plug_spec -> 
        create_from_atom plug_spec, env
      is_tuple plug_spec ->
        create_from_tuple plug_spec
      is_function plug_spec ->
        create_from_function plug_spec
      true ->
        raise "Unsupported plug format"
    end
  end
  
  defp create_from_atom(plug_spec, env) do
    cond do
      is_elixir_module(plug_spec) -> 
        Switchboard.Plug.Mod.new( module: plug_spec )
      is_registered_plug(plug_spec, env) -> 
        env.plugs[plug_spec]
      true ->
        raise "Unsupported plug format"
    end
  end
  
  defp is_elixir_module(module), do: match?("Elixir." <> _, atom_to_binary(module))
  
  defp create_from_tuple(args) do
    
  end
  
  defp is_registered_plug(plug_spec, env) do
  end
  
  defp create_from_function(args) do
    
  end
  
  
  
  
  
  
end