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
    modal = "<div id='#{@target}' class='#{@modalClass}
                  popup-full bg-none mfp-with-anim mfp-hide'></div>"

    $("body").append(modal) if $("body").find("##{@target}").length < 1
    target = $("body").find("##{@target}")
    target.html(@html).promise().done =>
      $.magnificPopup.open
        disableOn: 540
        preloader: true
        midClick: true
        removalDelay: 500
        fixedContentPos: true
        items: src: $("##{@target}")
        mainClass: "mfp-#{@animation}"
        callbacks: @callbacks
