Rails.application.routes.draw do
  # devise_for :users を1回だけ定義します
  devise_for :users, controllers: {
    registrations: 'users/registrations'  # ユーザー登録をカスタマイズしたい場合はここを指定
  }

  # スケジュールのルーティング
  resources :schedules, only: [:index, :create, :update, :destroy]

  # ルートページをスケジュール一覧ページに設定
  root 'schedules#index'
end
