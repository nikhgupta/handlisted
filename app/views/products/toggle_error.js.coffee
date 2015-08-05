message = "There was a problem with your request. Please, try again."
card = $(".product-card[data-pid='<%= @product.pid %>']")
card.find(".error").html(message)
