card = $("[data-pid='<%= @product.pid %>']")
like = card.find("a.like")
like.toggleClass('active')
like.find("i.fa").toggleClass('fa-heart fa-heart-o')
