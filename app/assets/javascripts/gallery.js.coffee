# isotope:     isotope.metafizzy.co
# live-tile:   http://www.drewgreenwell.com/projects/metrojs
# dialog-fx:   http://tympanus.net/Development/DialogEffects/
# owlCarousel: www.owlcarousel.owlgraphic.com
#
#= require pages-plugins/jquery-isotope/isotope.pkgd.min
#= require pages-plugins/jquery-metrojs/MetroJs
#= require pages-plugins/codrops-dialogFx/dialogFx
#= require pages-plugins/owl-carousel/owl.carousel
#= require pages-plugins/jquery-nouislider/jquery.nouislider.min
#
ready = ->
  gallery = $('.gallery')
  gallery.imagesLoaded -> applyIsotope()

  applyIsotope = ->
    gallery.isotope
      itemSelector: '.gallery-item'
      masonry:
        columnWidth: 280
        gutter: 10
        isFitWidth: true

  $('.live-tile,.flip-list').liveTile()

  $('body').on 'click', '.gallery-item', ->
    dlg = new DialogFx($('#itemDetails').get(0))
    dlg.toggle()

  $('.item-slideshow > div').each ->
    img = $(this).data('image')
    $(this).css
      'background-image': 'url(' + img + ')'
      'background-size': 'cover'

  $('.item-slideshow').owlCarousel
    items: 1
    nav: true
    navText: [
      '<i class="fa fa-chevron-left"></i>'
      '<i class="fa fa-chevron-right"></i>'
    ]
    dots: true

  $('[data-toggle="filters"]').click ->
    $('#filters').toggleClass 'open'
  $('#slider-margin').noUiSlider
    start: [
      20
      80
    ]
    margin: 30
    connect: true
    range:
      'min': 0
      'max': 100

$ -> ready()
