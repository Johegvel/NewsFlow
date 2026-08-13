class CreateCommunities < ActiveRecord::Migration[8.1]
  def change
    create_table :communities do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.string :topic

      t.timestamps
    end
    add_index :communities, :slug, unique: true
  end
end
