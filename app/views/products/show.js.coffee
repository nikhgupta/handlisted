<% if @pagination_for == "comments" %>
<%= j render("comments/lists/default", comments: @comments) %>
<% else %>
new MagnificModal
  html: "<%= j render('products/overview', presenter: present(@product), founder: present(@product.founder)) %>"
  modalClass: "productModal"
  animation: "zoomIn"
.open()
$.productCardify(".product.card")
<% end %>
