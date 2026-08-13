class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :community, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.integer :post_type
      t.integer :status
      t.datetime :published_at

      t.timestamps
    end
  end
end
