<% if @pagination_for == "comments" %>
<%= render("comments/lists/default", comments: @comments) %>
<% else %>
new MagnificModal
  html: "<%= j render('products/cards/overview', product: @product, presenter: present(@product)) %>"
  modalClass: "productModal"
  animation: "zoomIn"
.open()
$.productCardify("productCard")
<% end %>
