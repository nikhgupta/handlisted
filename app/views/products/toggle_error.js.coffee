message = "There was a problem with your request. Please, try again."
card = $(".productCard[data-pid='<%= @product.pid %>']")
card.find(".error").html(message)
