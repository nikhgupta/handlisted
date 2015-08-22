new magnificModal
  html: "<%= j render('info', product: @product, presenter: present(@product)) %>"
  modalClass: "product-info"
  animation: "zoomIn"
.open()
