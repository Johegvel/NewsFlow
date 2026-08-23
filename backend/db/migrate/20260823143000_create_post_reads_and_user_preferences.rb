class CreatePostReadsAndUserPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :post_reads do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.timestamps
    end
    add_index :post_reads, [:user_id, :post_id], unique: true

    create_table :user_preferences do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.boolean :reading_history_enabled, null: false, default: true
      t.boolean :personalization_enabled, null: false, default: true
      t.boolean :morning_digest_enabled, null: false, default: true
      t.boolean :curation_alerts_enabled, null: false, default: true
      t.timestamps
    end
  end
end
