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
#= require absolute-admin/jquery.validate.min
#= require absolute-admin/jquery.validate.additional.min
#= require absolute-admin/theme-utility-with-bootstrap
#= require absolute-admin/theme-core
#= require absolute-admin/plugins/magnific/jquery.magnific-popup
#= require products
#= require homepage
#= require product_adder
#= require_self

$ ->
  "use strict"

  Core.init()

  $('.navbar-search input').on 'focus', ->
    width = 0
    $("header.navbar > *:not('.navbar-search')").each -> width += $(@).width()
    $(@).attr "data-width", $(@).css('width')
    $(@).css 'width', $('header.navbar').width() - width - 100 + 'px'
    $(@).val "" if $(@).val() == $(@).attr("placeholder")
  $('.navbar-search input').on 'blur', ->
    $(@).css 'width', $(@).attr("data-width")
    $(@).removeAttr("data-width")
    $(@).val($(@).attr("placeholder")) unless $(@).val()?

  # Sidekiq Queue results on Search/Add Product Page
  new ProductAdder(
    form:  '.navbar-search',
    input: '#product_search'
    endpoints:
      search: "/products/search.json"
      status: "/products/status"
  ).init()
