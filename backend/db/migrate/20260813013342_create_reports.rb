class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.text :reason
      t.integer :status
      t.datetime :reviewed_at

      t.timestamps
    end
  end
end
