class Report < ApplicationRecord
  belongs_to :user
  belongs_to :post

  enum :status, {
    pending: 0,
    reviewed: 1,
    dismissed: 2,
    action_taken: 3
  }, default: :pending

  validates :reason, presence: true
end
