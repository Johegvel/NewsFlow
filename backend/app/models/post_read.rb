class PostRead < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: {
    scope: :post_id,
    message: "ya registró la lectura de esta publicación"
  }
end
