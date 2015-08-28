class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def create
    @commentable = find_commentable
    @comment = @commentable.comments.build(comment_params)
    respond_to do |format|
      if @comment.save
        format.html { redirect_to @commentable, notice: "Your comment has been added." }
        format.js do
          render partial: "comments/add", locals: {
            error: nil,
            comments: @commentable.reload.paginated_comments(page: params[:page]),
          }
        end
      else
        message  = "Encountered an error while adding your comment."
        message += " #{@comment.errors.full_messages.first}." if @comment.errors.any?
        format.html { redirect_to @commentable, alert: message }
        format.js do
          render partial: "comments/add", locals: {
            comment: @comment, commentable: @commentable, error: message
          }
        end
      end
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
