# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require bootstrap
#= require vendor/plugins/magnific/jquery.magnific-popup.js
#= require assets/js/utility/utility.js
#= require assets/js/main.js
#= require vendor/plugins/canvasbg/canvasbg.js
#= require_self

$ ->
  CanvasBG.init
    Loc:
      x: window.innerWidth / 2
      y: window.innerHeight / 3.3
  $('body').on 'contextmenu', '#demo-canvas', (e) -> false
