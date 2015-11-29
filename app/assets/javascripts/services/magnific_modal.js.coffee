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
    modal = "<div id='#{@target}' class='#{@modalClass} modal fade' role='dialog'> 
               <div class='modal-dialog modal-lg'>
                 <div class='modal-content'>
                   <button type=\"button\" class=\"close\" data-dismiss=\"modal\"
                   aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button>
                   #{@html}
                 </div>
               </div>
             </div>"

    $("body").append(modal) if $("body").find("##{@target}").length < 1
    target = $("body").find("##{@target}")
    target.html(@html).promise().done =>
      $("##{@target}").modal 'show'
      # $.magnificPopup.open
      #   disableOn: 540
      #   preloader: true
      #   midClick: true
      #   removalDelay: 500
      #   fixedContentPos: true
      #   items: src: $("##{@target}")
      #   mainClass: "mfp-#{@animation}"
      #   callbacks: @callbacks
