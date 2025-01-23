class Memo < ApplicationRecord

  validates :week_key, presence: true
  validates :day_index, presence: true
  validates :memo, presence: true


  def formatted_memo
    "メモ: #{memo}"
  end
end
