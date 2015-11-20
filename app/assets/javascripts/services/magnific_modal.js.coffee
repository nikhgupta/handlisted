# Allows wrapper for setting up a modal using `magnificPopup` with given
# options, and opening it quickly.
#
class @MagnificModal
  constructor: (options) ->
    @html       = options.html
    @modalClass = options.modalClass
    @callbacks  = options.callbacks
    @animation  = options.animation || 'fadeIn'
    @target     = "#{options.target_id || 'modal-panel'}"

  open: ->
    modal = "<div id='#{@target}' class='#{@modalClass} popup-full bg-none mfp-with-anim mfp-hide'></div>"
    $("##{@target}").remove()
    $('body').append(modal).promise().done =>
      $("##{@target}").html(@html).promise().done =>
        $.magnificPopup.open
          preloader: true
          midClick: true
          removalDelay: 500
          items: src: $("##{@target}")
          mainClass: "mfp-#{@animation}"
          callbacks: @callbacks
