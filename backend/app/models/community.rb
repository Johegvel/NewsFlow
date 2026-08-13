class Community < ApplicationRecord
  has_many :posts, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :topic, presence: true
end