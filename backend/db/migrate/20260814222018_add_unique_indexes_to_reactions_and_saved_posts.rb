class AddUniqueIndexesToReactionsAndSavedPosts < ActiveRecord::Migration[8.1]
  def change
    add_index :reactions,
              [:user_id, :post_id],
              unique: true,
              name: "index_reactions_on_user_and_post"

    add_index :saved_posts,
              [:user_id, :post_id],
              unique: true,
              name: "index_saved_posts_on_user_and_post"
  end
end