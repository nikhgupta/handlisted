<% if @pagination_for == "comments" %>
<%= render("comments/listing", comments: @comments) %>
<% else %>
new MagnificModal
  html: "<%= j render('info', product: @product, presenter: present(@product)) %>"
  modalClass: "product-info"
  animation: "zoomIn"
.open()
<% end %>
