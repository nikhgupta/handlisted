card = $("[data-pid='<%= @product.pid %>']")
like = card.find("a[data-like]")
like.attr "data-like", (if like.attr("data-like") is "on" then "off" else "on")
like.find("i.fa").toggleClass('fa-heart fa-heart-o')
