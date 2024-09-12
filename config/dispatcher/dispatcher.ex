defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: ["text/html", "application/xhtml+html"],
    json: ["application/json", "application/vnd.api+json"],
    upload: ["multipart/form-data"],
    sparql_json: ["application/sparql-results+json"],
    any: [ "*/*" ],
  ]

  define_layers [ :api, :frontend, :not_found ]

  ###############################################################
  # Backend layer
  ###############################################################
  match "/accounts", %{ accept: [:json], layer: :api} do
    Proxy.forward conn, [], "http://resource/accounts/"
  end

  match "/accounts/*path", %{ accept: [:json], layer: :api} do
    Proxy.forward conn, path, "http://accountdetail/accounts/"
  end

  match "/users/*path" do
    Proxy.forward conn, path, "http://cache/users/"
  end

  match "/persons/*path", %{ accept: [:json], layer: :api} do
    Proxy.forward conn, path, "http://cache/persons/"
  end

  match "/mock/sessions/*path", %{ accept: [:any], layer: :api} do
    Proxy.forward conn, path, "http://mocklogin/sessions/"
  end

  match "/sessions/*path" do
    Proxy.forward conn, path, "http://login/sessions/"
  end

  ###############################################################
  # frontend layer
  ###############################################################

  match "/assets/*path", %{layer: :api} do
    Proxy.forward(conn, path, "http://frontend/assets/")
  end

  match "/@appuniversum/*path", %{layer: :api} do
    Proxy.forward(conn, path, "http://frontend/@appuniversum/")
  end

  match "/*path", %{accept: [:html], layer: :api} do
    Proxy.forward(conn, [], "http://frontend/index.html")
  end

  match "/*_path", %{layer: :frontend} do
    Proxy.forward(conn, [], "http://frontend/index.html")
  end

  match "/*_", %{ layer: :not_found } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
