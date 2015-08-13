class Post < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  validates :title, uniqueness: true, presence: true

  has_many :comments
end
