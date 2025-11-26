# frozen_string_literal: true

DiscourseRewind::Engine.routes.draw do
  get "/rewinds" => "rewinds#index", :constraints => { format: :json }
  get "/rewinds/:index" => "rewinds#show", :constraints => { index: /\d+/ }
end

Discourse::Application.routes.draw { mount ::DiscourseRewind::Engine, at: "/" }
