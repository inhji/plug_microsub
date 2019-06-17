defmodule PlugMicrosub do
  @moduledoc """
  A plug for building a Microsub server.
  """
  use Plug.Router

  @supported_actions ["channels"]
  @supported_methods ["delete"]

  plug :match
  plug :dispatch

  def init(opts) do
    handler =
      Keyword.get(opts, :handler) || raise ArgumentError, "Microsub Plug requires :handler option"

    json_encoder =
      Keyword.get(opts, :json_encoder) ||
        raise ArgumentError, "Microsub Plug requires :json_encoder option"

    [handler: handler, json_encoder: json_encoder]
  end

  def call(conn, opts) do
    conn = put_private(conn, :plug_microsub, opts)
    super(conn, opts)
  end

  get "/" do
    with {:ok, action, conn} <- get_action(conn) do
      handle_action(conn, :get, action)
    else
      {:error, reason} ->
        send_error(conn, reason)
    end
  end

  post "/" do
    with {:ok, action, conn} <- get_action(conn),
    {:ok, method, conn} <- get_method(conn) do
      handle_action(conn, :post, action, method)
    else
      {:error, reason} ->
        send_error(conn, reason)
    end
  end

  match _ do
    send_resp(conn, 404, "Not found!")
  end

  def handle_action(conn, :get, :channels) do
    handler = get_opt(conn, :handler)

    with {:ok, channels} <- handler.handle_list_channels() do
      conn
      |> send_response(%{channels: channels})
    else
      {:error, code, reason} ->
        send_error(conn, reason, code)
    end
  end

  def handle_action(_conn, :post, :channels, :delete) do

  end

  def get_action(%{query_params: %{"action" => action}} = conn) do
    if not Enum.member?(@supported_actions, action) do
      {:error, "Unsupported action"}
    else
      {:ok, String.to_atom(action), conn}
    end
  end

  def get_action(%{query_params: _}), do: {:error, "Bad Request"}

  def get_method(%{query_params: %{"method" => method}} = conn) do
    if not Enum.member?(@supported_methods, method) do
      {:error, "Unsupported method"}
    else
      {:ok, String.to_atom(method), conn}
    end
  end

  def get_method(%{query_params: _} = conn), do: {:ok, nil, conn}

  def get_opt(conn, opt) do
    conn.private[:plug_microsub][opt]
  end

  def send_response(conn, response) do
    json_encoder = get_opt(conn, :json_encoder)
    body = json_encoder.encode!(response)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, body)
  end

  def send_error(conn, reason, code \\ :invalid_request) do
    json_encoder = get_opt(conn, :json_encoder)
    error_code = get_error_code(code)
    body =
      json_encoder.encode!(%{
        error: reason
      })

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(error_code, body)
  end

  def get_error_code(:insufficient_scope), do: :unauthorized
  def get_error_code(:invalid_request), do: :bad_request
  def get_error_code(code), do: code
end
