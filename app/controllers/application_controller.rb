class ApplicationController < ActionController::Base
    before_action :authenticate_user!  # ユーザーがサインインしていない場合、サインインページへリダイレクト
  end
  