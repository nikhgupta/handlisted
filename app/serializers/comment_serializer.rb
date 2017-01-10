class CommentSerializer < ActiveModel::Serializer
  attributes :id, :comment, :updated_at, :timestamp
  attributes :user, :error

  def timestamp
    scope.time_ago_in_words object.updated_at if object.persisted?
  end

  def error
    object.errors.full_messages.first
  end
end
