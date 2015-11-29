#= require social-share-button

ready = ->
  el = $('.social-share-button')
  if el.length > 0
    el.prepend("<span>Share on: </span>").find("a").each ->
      site = $(@).attr("data-site")
      $(@).html("<i class='fa fa-2x fa-#{site.replace('_', '-')}'></i>")
      $(@).addClass('hidden-xs') if site in ["delicious", "tumblr"]

$ -> ready()
