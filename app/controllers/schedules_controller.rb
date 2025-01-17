class SchedulesController < ApplicationController
  before_action :authenticate_user!

  def create
    @schedule = current_user.schedules.new(schedule_params)
    if @schedule.save
      redirect_to schedules_path, notice: '予定を追加しました。'
    else
      render :index
    end
  end

  def update
    @schedule = current_user.schedules.find(params[:id])
    if @schedule.update(schedule_params)
      redirect_to schedules_path, notice: '予定を更新しました。'
    else
      render :index
    end
  end

  def destroy
    @schedule = current_user.schedules.find(params[:id])
    @schedule.destroy
    redirect_to schedules_path, notice: '予定を削除しました。'
  end

  private

  def schedule_params
    params.require(:schedule).permit(:date, :text, :start_time, :end_time, :important)
  end
end
