card = $('#<%= present(@product).id @kind %>')
<% if @success.present? %>
card.find(".product-like").toggleClass('active').find(".fa").toggleClass('fa-heart fa-heart-o')
<% else %>
card.portlet error: "Encountered an error! Please, try again."
<% end %>
