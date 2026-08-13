class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community

  has_many :comments, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :reports, dependent: :destroy

  enum :post_type, {
    discussion: 0,
    question: 1,
    opinion: 2
  }, default: :discussion

  enum :status, {
    draft: 0,
    published: 1,
    hidden: 2
  }, default: :published

  validates :title, presence: true
  validates :content, presence: true
end