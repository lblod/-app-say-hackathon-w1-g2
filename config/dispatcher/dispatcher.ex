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
  match "/administrative-units/*path", %{accept: [:json], layer: :api} do
    Proxy.forward(conn, path, "http://cache/administrative-units/")
  end
  ###############
  # LOGIN
  ###############
  match "/sessions/*path" do
    Proxy.forward conn, path, "http://login/sessions/"
  end

  match "/accounts", %{accept: [:json], layer: :api} do
    Proxy.forward(conn, [], "http://resource/accounts/")
  end

  match "/users/*path" do
    Proxy.forward conn, path, "http://cache/users/"
  end

  match "/accounts/*path", %{accept: [:json], layer: :api} do
    Proxy.forward(conn, path, "http://accountdetail/accounts/")
  end

  match "/groups/*path", %{ accept: [:json], layer: :api} do
    Proxy.forward conn, path, "http://cache/groups/"
  end

  match "/sites/*path", %{ accept: [:json], layer: :api} do
    Proxy.forward conn, path, "http://cache/sites/"
  end

  match "/mock/sessions/*path", %{ accept: [:any], layer: :api} do
    Proxy.forward conn, path, "http://mocklogin/sessions/"
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

  match "/groups/*path", %{accept: [:json], layer: :api} do
    Proxy.forward(conn, path, "http://resource/groups/")
  end

  ###############################################################
  # Not found
  ###############################################################
  match "/*_", %{accept: [:any], layer: :not_found} do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
