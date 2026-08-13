class SavedPost < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: {
    scope: :post_id,
    message: "ya guardaste esta publicación"
  }
end