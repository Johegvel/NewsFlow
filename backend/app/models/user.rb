class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :reports, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end