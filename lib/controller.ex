defmodule ApiCommons.Controller do
  @moduledoc """

  """

  defmacro __using__(opts) do
    allow_specific_renders = Keyword.get(opts, :specifc_renders)
    quote do

      @doc """

      """
      def has_request_body(conn) do
        if map_size(conn.body_params) == 0 do
          {:error, %{
            code: 1001,
            msg: "Missing request body."
          }}
        else
          true
        end
      end

      if unquote(allow_specific_renders) do
        defp process_entity(conn, content, key, opts \\ %{})
        defp process_entity(conn, content, key, opts) do
          case content do
            {:error, _} -> process(conn, content)
            _ -> render_entity(conn, content, key, opts)
          end
        end
      end

      # TODO: put status into conn with "put_status"
      # Without parameters
      defp process(conn, content, opts \\ %{})
      defp process(conn, {:error, [_ | _] = errors}, opts) do
        conn
        |> put_status_in_conn(errors)
        |> put_view(SpaceTimeWeb.ApiErrorResponse)
        |> render("generic_error.json", %{multiple_errors: errors})
      end

      defp process(conn, {:error, error}, opts) do
        conn
        |> put_status_in_conn(error)
        |> put_view(SpaceTimeWeb.ApiErrorResponse)
        |> render("generic_error.json", error)
      end

      defp process(conn, entity, opts) do
        conn
        |> render_entity(entity, opts)
      end

      # ----------
      # Map error code to HTTP Error
      # ------------------------

      defp put_status_in_conn(conn, [_ | _]) do
        conn
        |> put_status(:bad_request)
      end

      defp put_status_in_conn(conn, %{code: 1000, msg: _}) do
        conn
        |> put_status(:not_found)
      end

      defp put_status_in_conn(conn, %{code: 1001, msg: _}) do
        conn
        |> put_status(:bad_request)
      end

      defp put_status_in_conn(conn, _), do: conn

    end
  end
end
