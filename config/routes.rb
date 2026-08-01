KeystoneUi::Colors::Engine.routes.draw do
  get "/", to: "settings#show", as: :settings
  patch "/", to: "settings#update"
  delete "/", to: "settings#destroy"
end
