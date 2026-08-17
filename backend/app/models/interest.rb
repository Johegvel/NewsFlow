class Interest < ApplicationRecord
  has_many :user_interests, dependent: :destroy
  has_many :users, through: :user_interests

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end