class AddUniqueIndexToUserInterests < ActiveRecord::Migration[8.1]
  def change
    add_index :user_interests,
          [:user_id, :interest_id],
          unique: true
  end
end
