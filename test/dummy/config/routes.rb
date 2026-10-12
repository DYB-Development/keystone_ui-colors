# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"
  get "about", to: "home#index", as: :about
  mount KeystoneUi::Colors::Engine => "/keystone_ui_colors"
end
