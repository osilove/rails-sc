Rails.application.routes.draw do
  resources :schedules, only: [:index, :create, :update, :destroy] do
    resources :memos, only: [:index, :create, :destroy]
  end

  post '/add_memo', to: 'memos#create'
  get '/load_memos', to: 'memos#index'  # ここでデータを取得するエンドポイントを追加
  get 'read_memos', to: 'memos#read_memos'
  root 'schedules#index'
end
