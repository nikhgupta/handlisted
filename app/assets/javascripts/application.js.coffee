# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#

#= require jquery
#= require jquery_ujs
#= require riot
#= require riot_rails

# BEGIN VENDOR JS FOR PAGES (plus add in jquery.turbolinks)
#= require pages-plugins/pace/pace.min
# require pages-plugins/jquery/jquery-1.11.1.min
#= require pages-plugins/modernizr.custom
#= require pages-plugins/jquery-ui/jquery-ui.min
#= require pages-plugins/boostrapv3/js/bootstrap.min
#= require pages-plugins/jquery/jquery-easy
#= require pages-plugins/jquery-unveil/jquery.unveil.min
#= require pages-plugins/jquery-bez/jquery.bez.min
#= require pages-plugins/jquery-ios-list/jquery.ioslist.min
#= require pages-plugins/imagesloaded/imagesloaded.pkgd.min
#= require pages-plugins/jquery-actual/jquery.actual.min
#= require pages-plugins/jquery-scrollbar/jquery.scrollbar.min
#= require frontend/pages-plugins/velocity/velocity.min
#= require frontend/pages-plugins/velocity/velocity.ui
#= require frontend/pages-plugins/waypoints/jquery.waypoints.min
#= require frontend/pages-plugins/jquery-appear/jquery.appear
#= require frontend/pages-plugins/animateNumber/jquery.animateNumbers
#= require frontend/pages-plugins/jquery-unveil/jquery.unveil.min
#= require frontend/pages-core/js/pages.frontend
#= require pages-plugins/jquery-validation/js/jquery.validate.min

# BEGIN CORE TEMPLATE JS FOR PAGES
#= require pages-core/js/pages

# BEGIN SITE SCRIPTS

#  I prefer to list scripts in a specific order, so I comment out require_tree .
## require_tree .
## require turbolinks


# Custom scripts
# require gallery
#
#= require services/status_poller
#= require services/social-sharing
#= require services/forms_validator
#= require services/newsletter_subscriber
#= require services/magnific_modal

#= require_self
#= require components/raw
#= require components/progress_bar
#= require components/product_card
#= require components/product_overview
#= require components/products_listing
#= require components/user_card
#= require components/users_listing
#= require components/sitewide_search

# redirect unauthorized XHR requests to login page
$(document).ajaxError (e, XHR, options) ->
  message = "You need to sign in or sign up before continuing."
  if XHR.status is 401 and (XHR.responseText is message or XHR.responseJSON?.error is message)
    window.location.replace("/login?unauthorized")

# override overlay toggle fn. to fix scrolling issues
tgOld = $.fn.search.Constructor.prototype.toggleOverlay
$.fn.search.Constructor.prototype.toggleOverlay = (action, key) ->
  tgOld.apply(@, [action, key])
  if action is 'show'
    @$element.scrollTop = 0
    $("body").addClass 'noscroll has-overlay'
    @$element.attr("aria-hidden", false)
    @$element.trigger('show')
  else
    $("body").removeClass 'noscroll has-overlay'
    @$element.attr("aria-hidden", true)
    @$element.trigger('hide')

# $.ajax
#   complete:   -> $(".ajax-loader").hide()
#   beforeSend: -> $(".ajax-loader").show()

ready = ->

  if $('[data-toggle="velocity"]').length > 0
    $('[data-toggle="velocity"]').click ->
      $($(@).attr('data-target')).velocity 'scroll', duration: 800

  $(".panel-scrollable").each -> $(@).css "height", $(@).height() + 20

  if $(window).scrollTop() > 10
    $('nav.header').header('addMinimized')

  new FormsValidator('form').init()
  # new FormsValidator('form', errorClass: 'state-error', validClass: 'state-success', errorElement: "em").init()

  # new SiteWideSearch('[data-pages="search"]').init()

  # $("[data-pages='search']").data("pg.search").toggleOverlay("show")
$ -> ready()
