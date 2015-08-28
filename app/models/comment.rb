class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  scope :recent, -> { order(created_at: :desc) }

  validates :comment, length: { minimum: 20 }

  before_save :strip_whitespace

  private

  def strip_whitespace
    self.comment = self.comment.strip
  end
end
