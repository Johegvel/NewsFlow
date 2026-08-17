class CreateInterests < ActiveRecord::Migration[8.1]
  def change
    create_table :interests do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end
    add_index :interests, :slug, unique: true
  end
end
