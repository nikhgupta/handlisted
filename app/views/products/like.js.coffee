card = $("[data-pid='<%= @product.pid %>']")
card.find("a[data-like]").replaceWith('<%= j present(@product).like_button %>')
