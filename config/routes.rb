Rails.application.routes.draw do
  resources :schedules, only: [:index, :create, :update, :destroy] do
    resources :memos, only: [:index, :create, :destroy]
  end

  post '/add_memo', to: 'memos#create'

root 'schedules#index'
end