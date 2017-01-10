<product-comments>
  <div class="row">
    <div class="col-md-12 m-b-10">
      <div class="widget-1-wrapper">
        <div class="panel">
          <div class="panel-body no-padding">
            <div class="p-t-10 p-b-20">

              <div if={ is_logged_in } class="comment-form m-b-10">
                <form action="#" method="post">
                  <div class="row p-t-20 p-l-20 p-r-20">
                    <user-card user={ parent.current_user }></user-card>
                    <div class="col-sm-10 no-padding">
                      <span class="text-black bold">{ parent.current_user.name }</span>
                      <div class="input-group transparent no-border full-width">
                        <textarea name="comment[comment]" id="comment_comment" rows=2 placeholder="Write a comment"
                          class="no-border fs-14 p-l-0 p-t-5 p-b-10 full-width"></textarea>
                      </div>
                      <div class="clearfix">
                        <button type="submit" class="btn btn-success font-montserrat text-uppercase fs-12" onclick="{ add_comment }">Add Comment</button>
                        <img if={ajaxip} class="ajax-loader" src='/images/ajax-loader.gif' width="24" height="24" />
                        <strong if={result} class="comment-result { result.error ? 'text-danger' : 'text-success'}">{ result.error ? result.error : "Comment Posted!" }</strong>
                      </div>
                    </div>
                  </div>
                </form>
              </div>

              <virtual if={ !is_logged_in }>
                <div class="alert alert-warning" role="alert">
                  <button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                  <p>Please, <a href="/login" target="_blank">login</a> to add comments.</p>
                </div>
              </virtual>

              <virtual show={ comments.length > 0 } each={comment, index in comments}>
                <div class="comment row { index % 2 == 1 ? 'alternate' : '' }">
                  <user-card user={comment.user}></user-card>
                  <div class="col-sm-10 col-xs-12 no-padding">
                    <p>{ comment.comment }</p>
                    <div class="clearfix">
                      <div class="pull-left small hint-text">about { comment.timestamp } ago</div>
                    </div>
                  </div>
                </div>
              </virtual>

              <virtual show={ comments.length == 0 }>
                <div class="alert alert-sm alert-dark pastel">
                  <i class="fa fa-cubes pr10"></i>
                  Oh snap! <strong>No comments were found for this product.</strong>
                  Perhaps, you would like to post a new comment?
                </div>
              </virtual>

              <div class="pagination-nav">
                <a class="btn btn-success font-montserrat text-uppercase fs-12" onclick="{ previous_comments }">&laquo; Previous</a>
                <a class="btn btn-success font-montserrat text-uppercase fs-12" onclick="{ next_comments }">Next &raquo;</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <style type='text/scss'>
    .user.card {
      margin-right: 20px;
    }
    .comment {
      padding: 10px 20px;
      background-color: #f8f8f8;
    }
    .comment-result {
      margin-left: 10px;
    }
    .pagination-nav {
      margin-top: 10px;
    }
  </style>

  <script type="text/coffee">
    @comments = opts.comments || parent.comments || []
    @is_logged_in = @parent.current_user?
    @ajaxip = false

    @add_comment = (e) ->
      e.preventDefault()
      @ajaxip = true; @result = null; @update()
      $.post "/products/#{@parent.product.id}/comments.json", comment: {
        comment: $("#comment_comment").val()
      }, (result) =>
        if not (@result = result).error?
          $("#comment_comment").val("")
          @comments.unshift result
        @ajaxip = false; @update()
  </script>
</product-comments>
