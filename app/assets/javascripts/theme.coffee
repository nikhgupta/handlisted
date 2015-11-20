#= require absolute-admin/jquery.validate.min
#= require absolute-admin/jquery.validate.additional.min
#= require absolute-admin/theme-utility-with-bootstrap
#= require absolute-admin/theme-core
#= require absolute-admin/plugins/magnific/jquery.magnific-popup

# initialize the theme
ready = ->
  Core.init()

$(document).ready(ready)
$(document).on('pages:load', ready)
