class SchedulesController < ApplicationController
  # スケジュール作成
  def create
    @schedule = Schedule.new(schedule_params)
    if @schedule.save
      redirect_to schedules_path, notice: '予定を追加しました。'
    else
      render :index
    end
  end

  # スケジュール更新
  def update
    @schedule = Schedule.find(params[:id])
    if @schedule.update(schedule_params)
      redirect_to schedules_path, notice: '予定を更新しました。'
    else
      render :index
    end
  end

  # スケジュール削除
  def destroy
    @schedule = Schedule.find(params[:id])
    @schedule.destroy
    redirect_to schedules_path, notice: '予定を削除しました。'
  end

  # メモ追加
  def add_memo
    @schedule = Schedule.find(params[:schedule_id]) # スケジュールIDでスケジュールを取得
    if @schedule.update(memo: params[:memo]) # メモを更新
      render json: { success: true }, status: :ok
    else
      render json: { error: 'メモの追加に失敗しました' }, status: :unprocessable_entity
    end
  end

  private

  # スケジュール作成・更新時に許可するパラメータ
  def schedule_params
    params.require(:schedule).permit(:week_key, :date, :start_time, :end_time, :text, :important)
  end
end
