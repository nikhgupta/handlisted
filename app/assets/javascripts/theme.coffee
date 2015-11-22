#= require absolute-admin/jquery.validate.min
#= require absolute-admin/jquery.validate.additional.min
#= require absolute-admin/theme-utility-with-bootstrap
#= require absolute-admin/theme-core
#= require absolute-admin/plugins/magnific/jquery.magnific-popup
#= require absolute-admin/plugins/canvasbg/canvasbg

# initialize the theme
ready = ->
  Core.init()

  CanvasBG.init() if $("#demo-canvas").length > 0
  $('body').on 'contextmenu', '#demo-canvas', (e) -> false

$(document).ready(ready)
$(document).on('pages:load', ready)
