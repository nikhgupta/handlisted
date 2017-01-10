class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def create
    @commentable = find_commentable
    @comment = @commentable.comments.create(comment_params)
    @comments = @commentable.reload.paginated_comments(page: params[:page])

    @error  = "Encountered an error while adding your comment."
    @error += " #{@comment.errors.full_messages.first}." if @comment.errors.any?
    @error  = nil if @comment.persisted?

    options = @comment.persisted? ? { notice: "Your comment has been added." } : { alert: @error }

    respond_to do |format|
      format.json { render json: @comment }
      format.html { redirect_to @commentable, options }
    end
  end

  private
  def find_commentable
    params.each do |name, value|
      return $1.classify.constantize.find(value) if name =~ /(.+)_id$/
    end
    nil
  end

  def comment_params
    params.require(:comment).permit(:comment).merge(user_id: current_user.id)
  end
end
