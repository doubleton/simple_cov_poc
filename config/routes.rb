Rails.application.routes.draw do
  root 'posts#index'
  resources :posts do
    resources :comments
  end

  resources :testings, only: [:index, :show, :destroy]

end
