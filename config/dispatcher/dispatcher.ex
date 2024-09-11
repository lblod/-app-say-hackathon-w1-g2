defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ]
  ]

  @any %{}
  @json %{ accept: %{ json: true } }
  @html %{ accept: %{ html: true } }

  define_layers [ :static, :services, :fall_back, :not_found ]

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
