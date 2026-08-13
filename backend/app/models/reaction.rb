class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :post

  enum :kind, {
    like: 0,
    helpful: 1,
    interesting: 2
  }, default: :like

  validates :user_id, uniqueness: {
    scope: :post_id,
    message: "ya reaccionó a esta publicación"
  }
end