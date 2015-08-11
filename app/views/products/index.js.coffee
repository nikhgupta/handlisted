<% @products.each do |product| %>
$('.product-index').append "
<div class='col-sm-6 col-md-4'>
  <%= j render('products/card', product: product, presenter: present(product)) %>
</div>
"
<% end %>
<% if @products.last_page? %>
$('.paginator').html("<p class='bg-header'><strong>Whoa! You've reached the end of the world!</strong></p>")
<% else %>
$('.pagination').replaceWith '<%= j paginate(@products) %>'
<% end %>

