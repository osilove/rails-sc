class ApplicationController < ActionController::Base
  # CSRF対策の設定（検証をスキップする例も含む）
  protect_from_forgery with: :exception # CSRFトークンを強制的に確認
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? } # JSONリクエスト時はCSRFをスキップ
  
  # レスポンスをJSONにフォーマットするヘルパー
  before_action :set_default_response_format
  
  private
  
  # デフォルトのレスポンスフォーマットをJSONに設定
  def set_default_response_format
  request.format = :json if request.format.html? == false
  end
  end
  