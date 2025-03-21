class CreateSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :schedules do |t|
      t.date :date
      t.text :text
      t.time :start_time
      t.time :end_time
      t.boolean :important
      t.text :memo
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
