#= require absolute-admin/plugins/slick/slick

$ ->

  if $('body').hasClass('static-page')
    $("#sidebar_left").hide()
    $('#toggle_sidemenu_l').hide()
    $("#content_wrapper").css("margin-left", "0")
    $('.home-page-slider').slick dots: false
