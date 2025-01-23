class MemosController < ApplicationController
  require 'yaml'
  
  # CSRFトークンの検証をスキップ
  skip_before_action :verify_authenticity_token, only: [:create]
  
  def create
    # パラメータの検証
    if params[:weekKey].blank? || params[:dayIndex].blank? || params[:memo].blank?
      Rails.logger.error("パラメータが不足しています: #{params.inspect}")
      render json: { error: 'パラメータが不足しています' }, status: :unprocessable_entity
      return
    end
    
    # メモの作成
    memo = {
      week_key: params[:weekKey],
      day_index: params[:dayIndex],
      memo: memo_params.to_h # ここでParametersをハッシュに変換
    }
    
    # YAMLファイルへの保存
    save_memo(memo)
    
    render json: { message: 'メモが保存されました', memo: memo }, status: :ok
  rescue StandardError => e
    Rails.logger.error("メモの保存中にエラーが発生しました: #{e.message}")
    render json: { error: 'メモの保存中にエラーが発生しました' }, status: :internal_server_error
  end
  
  private
  
  # Strong Parameters
  def memo_params
    params.require(:memo).permit(:text, :startTime, :endTime, :important)
  end
  
  def save_memo(memo)
    memos = load_memos
  
    Rails.logger.info("Loaded memos: #{memos.inspect}")
  
    # 既存のメモを検索
    existing_memo = memos.find { |m| m[:week_key] == memo[:week_key] && m[:day_index] == memo[:day_index] }
    Rails.logger.info("Existing memo: #{existing_memo.inspect}")
  
    if existing_memo
      # 既存のメモがある場合
      if existing_memo[:memo].is_a?(Hash)
        # memoがHashの場合、そのまま更新
        existing_memo[:memo] = memo[:memo]
      elsif existing_memo[:memo].is_a?(Array)
        # 既存のメモが配列の場合、そのまま追加
        existing_memo[:memo] << memo[:memo]
      end
    else
      # 新しいメモを追加
      memos << memo
    end
  
    # YAMLファイルに保存
    File.open(Rails.root.join('memos.yml'), 'w') { |file| file.write(memos.to_yaml) }
    Rails.logger.info("Memos saved to file")
  end
  
  
  # メモを読み込むメソッド
  def load_memos
    file_path = Rails.root.join('memos.yml')
    if File.exist?(file_path)
      begin
        # Permitted classesにSymbolを追加
        YAML.load_file(file_path, permitted_classes: [ActiveSupport::HashWithIndifferentAccess, ActionController::Parameters, Symbol]) || [] 
      rescue StandardError => e
        Rails.logger.error("YAMLの読み込みに失敗しました: #{e.message}")
        []
      end
    else
      []
    end
  end
end
