defmodule ApiCommons.Model do
  @moduledoc """
  Basic error handling for phoenix models.

  """

  defmacro __using__(opts) do
    manual_fields = Keyword.get(opts, :manual, [])

    quote do

      # Put this functions in method
      def parse_changeset_to_error(%{errors: errors, valid?: false}) do
        errors = parse_errors(errors)
      end

      defp parse_errors(errors, acc \\ [])
      defp parse_errors([], acc), do: acc
      defp parse_errors([{key, error} = complete | tail], acc) do
        parse_errors(tail, [pre_process_error_code(key, error) | acc])
      end

      # --------
      # Pre-process the changeset errors into short error codes
      # --------------

      # TODO: remove when pusblish into library (custom error, only in timezone.ex)
      defp pre_process_error_code(key, {"does not exist", info}) do
        entity_name = Keyword.get(info, :entity)
        error_to_json(key, :not_existing, %{entity: entity_name})
      end

      defp pre_process_error_code(key, {"can't be blank", _}) do
        error_to_json(key, :missing)
      end

      defp pre_process_error_code(key, {"is invalid", info}) do
        key_type = Keyword.get(info, :type)
        |> preprocess_key_type()

        error_to_json(key, String.to_atom("is_invalid_#{key_type}"))
      end

      defp pre_process_error_code(key, {"has already been taken", _}) do
        error_to_json(key, :already_taken)
      end

      defp pre_process_error_code(key, error) do
        error_to_json(key, error)
      end

      defp preprocess_key_type(key_type) when is_tuple(key_type) do
        key_type
        |> Tuple.to_list()
        |> Enum.join("_")
      end
      defp preprocess_key_type(key_type), do: key_type

      # -------
      # Transform errors into some error
      # -------------------------------

      # defp error_to_json(field_key, error_key, opts \\ %{})
      defp error_to_json(field_key, :not_existing, %{entity: entity_name})
      when field_key not in unquote(manual_fields)
      do
        %{
          code: 1000,
          msg: ""
        }
      end

      defp error_to_json(field_key, :missing)
      when field_key not in unquote(manual_fields)
      do
        %{
          code: 1001,
          msg: "Missing required field '#{field_key}'."
        }
      end

      defp error_to_json(field_key, :alredy_taken)
      when field_key not in unquote(manual_fields)
      do
        %{
          code: 1001,
          msg: "An entry with given value for '#{field_key}' already exists."
        }
      end

      defp error_to_json(key, :is_invalid_string)
      when key not in unquote(manual_fields)
      do
        %{
          code: 1001,
          msg: "Invalid field type. Expected '#{key}' to be of type string."
        }
      end

      defp error_to_json(key, :is_invalid_array_map)
      when key not in unquote(manual_fields)
      do
        %{
          code: 1001,
          msg: "Invalid field type. Expected '#{key}' to be an array of objects."
        }
      end

      defp error_to_json(key, :is_invalid_utc_datetime)
      when key not in unquote(manual_fields)
      do
        %{
          code: 1001,
          msg: "Invalid field type. Expected '#{key}' to be a valid date time."
        }
      end

      defp error_to_json(key, :is_invalid_integer)
      when key not in unquote(manual_fields)
      do
        %{
          code: 1001,
          msg: "Invalid field type. Expected '#{key}' to be of type integer."
        }
      end

      defp error_to_json(key, :is_invalid_float)
      when key not in unquote(manual_fields)
      do
        %{
          code: 1001,
          msg: "Invalid field type. Expected '#{key}' to be of type float."
        }
      end

      # -----------
      # Helper
      # --------------

      # Check if a specific key has specific prefix
      # Helpfulf for custom error_to_json
      defp of_prefix(key, prefix) do
        key_string = Atom.to_string(key)
        prefix_string = Atom.to_string(prefix)
        String.contains?(key_string, prefix_string)
      end

      # Remove a prefix from a key
      defp wh_prefix(key, prefix) do
        key_string = Atom.to_string(key)
        prefix_string = Atom.to_string(prefix)

        sliced = String.slice(
          key_string,
          String.length(prefix_string)+1,
          String.length(key_string)
        )

        String.to_atom(sliced)
      end

    end
  end

end
