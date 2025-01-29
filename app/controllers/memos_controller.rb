class MemosController < ApplicationController
  require 'yaml'
  require 'active_support/core_ext/hash/indifferent_access'

  # CSRFトークンの検証をスキップ
  skip_before_action :verify_authenticity_token, only: [:create, :update]

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

  def update
    if params[:weekKey].blank? || params[:dayIndex].blank? || params[:memo].blank?
      Rails.logger.error("パラメータが不足しています: #{params.inspect}")
      render json: { error: 'パラメータが不足しています' }, status: :unprocessable_entity
      return
    end

    # メモの更新
    updated_memo = {
      week_key: params[:weekKey],
      day_index: params[:dayIndex],
      memo: memo_params.to_h
    }

    update_memo_in_file(updated_memo)

    render json: { message: 'メモが更新されました', memo: updated_memo }, status: :ok
  rescue StandardError => e
    Rails.logger.error("メモの更新中にエラーが発生しました: #{e.message}")
    render json: { error: 'メモの更新中にエラーが発生しました' }, status: :internal_server_error
  end

  def load_memos
    file_path = Rails.root.join('memos.yml')

    if File.exist?(file_path)
      begin
        # YAML.safe_loadでデータを読み込む
        memo_data = YAML.safe_load(
          File.read(file_path),
          permitted_classes: [Symbol, ActiveSupport::HashWithIndifferentAccess],
          aliases: true
        ) || []

        # 読み込んだデータをwith_indifferent_accessに変換
        memo_data = memo_data.map(&:with_indifferent_access)
        return memo_data
      rescue Psych::DisallowedClass => e
        Rails.logger.error("YAMLの読み込みに失敗しました: #{e.message}")
      rescue StandardError => e
        Rails.logger.error("予期しないエラーが発生しました: #{e.message}")
      end
    end

    # ファイルが見つからない、またはエラーが発生した場合は空配列を返す
    []
  end

  def read_memos
    memos = load_memos
    render json: { memos: memos }, status: :ok
  end

  def index
    # memos.ymlからメモを読み込む
    yaml_memos = load_memos

    # データベースからメモを取得
    db_memos = Memo.all.map { |memo| memo.attributes.symbolize_keys }

    # memos.ymlとデータベースのメモを統合する
    combined_memos = yaml_memos + db_memos

    render json: { memos: combined_memos }, status: :ok
  end

  private

  # Strong Parameters
  def memo_params
    params.require(:memo).permit(:text, :startTime, :endTime, :important).tap do |memo|
      # startTime と endTime の形式を検証する（必要に応じて）
      if memo[:startTime] && !valid_time_format?(memo[:startTime])
        raise "Invalid startTime format"
      end
      if memo[:endTime] && !valid_time_format?(memo[:endTime])
        raise "Invalid endTime format"
      end
    end
  end

  # 時間形式の検証用メソッド
  def valid_time_format?(time_str)
    # 簡単な時間フォーマットの検証を行う
    !!(time_str =~ /\A\d{2}:\d{2}\z/)
  end

  def save_memo(memo)
    memos = load_memos

    # 既存のメモを検索
    existing_memo = memos.find { |m| m[:week_key] == memo[:week_key] && m[:day_index] == memo[:day_index] }

    if existing_memo
      # 既存のメモがある場合、配列として統一
      existing_memo[:memo] = Array(existing_memo[:memo])
      existing_memo[:memo] << memo[:memo]
      existing_memo[:memo].flatten! # ネストされた配列を平坦化
    else
      # 新しいメモを追加
      memos << memo
    end

    # YAMLファイルに保存
    File.open(Rails.root.join('memos.yml'), 'w') { |file| file.write(memos.to_yaml) }
  end

  def update_memo_in_file(updated_memo)
    memos = load_memos
    updated = false

    # 更新するメモを見つけて内容を更新
    memos.each do |memo|
      if memo[:week_key] == updated_memo[:week_key] && memo[:day_index] == updated_memo[:day_index]
        memo[:memo] = updated_memo[:memo]
        updated = true
        break
      end
    end

    if updated
      # 更新された内容をファイルに保存
      File.open(Rails.root.join('memos.yml'), 'w') { |file| file.write(memos.to_yaml) }
    else
      raise "更新対象のメモが見つかりません"
    end
  end
end
