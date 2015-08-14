Rails.application.routes.draw do
  namespace :api do
    match '*path' => 'application#render_nothing', via: [:options]
    resources :posts
    resources :comments
    resources :categories
  end
end
