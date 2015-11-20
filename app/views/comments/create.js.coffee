$('.new-comment-error').slideUp()

<% if @error.present? %>

$('.new-comment-error').html("
  <div class='alert alert-danger alert-dismissable' role='alert'>
    <button type='button' class='close' data-dismiss='alert'>
      <span aria-hidden='true'>×</span><span class='sr-only'>Close</span>
    </button>
    <%= @error %>
  </div>
").promise().done(-> $(this).slideDown())

<% else %>
<%= render('comments/lists/default', comments: @comments) %>
$("#comment_comment").val("").parent().removeClass("state-success state-error")

<% end %>
