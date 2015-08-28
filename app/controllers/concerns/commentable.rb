require 'active_support/concern'

module Commentable
  extend ActiveSupport::Concern

  included do
    before_filter :comments, only: [:show]
  end

  def comments
    @commentable = find_commentable
    @pagination_for = params[:resource]
    @comments = @commentable.paginated_comments(page: params[:page])
    @comment = Comment.new
  end

  private

  def find_commentable
    return params[:controller].singularize.classify.constantize.find(params[:id])
  end
end
