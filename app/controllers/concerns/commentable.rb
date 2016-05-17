require 'active_support/concern'

module Commentable
  extend ActiveSupport::Concern

  included do
    before_filter :comments, only: [:show]
  end

  def comments
    # per_page = params[:per_page] || Kaminari.config.default_per_page
    per_page = params[:per_page] || 3
    @commentable = find_commentable
    @pagination_for = params[:resource]
    @comments = @commentable.paginated_comments(page: params[:page], per_page: per_page)
    @comment = Comment.new
  end

  private

  def find_commentable
    return params[:controller].singularize.classify.constantize.find(params[:id])
  end
end
