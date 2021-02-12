Rails.application.routes.draw do
  get "/healthcheck", to: "application#healthcheck"
  match "/inbound/sms", to: "sms#inbound", via: [:post, :get, :put, :delete, :patch]
  post "/outbound/sms", to: "sms#outbound", via: [:post, :get, :put, :delete, :patch]
end
