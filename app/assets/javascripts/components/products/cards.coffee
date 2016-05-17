class @ProductCard
  constructor: (@element, @type) ->
    @timer = null
    @card  = $(@element)
    @image   = @card.find('.image-container')
    @related = @card.find('.related-product')

  init: ->
    @card.addClass('cardified')
    @card.on 'poll', @onPoll
    @attachModal() if @type is "default"
    @attachToRelatedProducts() if @type is "overview"

  onPoll: (e, job_id) =>
    @card.portlet
      refresh: true
      progress: 'bar'
      progressColor: 'default'
      onRefresh: => @statusPollerFor(job_id).init()

  statusPollerFor: (job_id) -> new StatusPoller
    job_id: job_id
    onTick: (response) => @setProgressBarTo(response.status)
    onComplete: (response) => $.getScript "/products/#{response.id}.js", type: @cardType()

  cardType: ->
    return 'overview' if @card.hasClass 'overview'
    if @card.hasClass('mini') then 'mini' else 'default'

  setProgressBarTo: (status) ->
    @pbar = @card.find ".progress-bar-indeterminate"
    colors = ["default", "master", "warning", "info", "success", "danger"]
    @pbar.removeClass("progress-bar-#{color}") for color in colors
    @pbar.addClass "progress-bar-#{@statusMap[status]}"

  statusMap:
    "": "default",
    "Queued": "master",
    "Working": "warning",
    "Complete": "success",
    "Failed": "danger"

  _openModalOrPage: (nodes, cb) ->
    nodes.on 'click', (e) ->
      url = cb($(@))
      if $(window).width() < 540
        window.location = url
      else
        e.preventDefault()
        $.getScript "#{url}.js"

  attachModal: ->
    @_openModalOrPage @image, (node) ->
      card = node.parents(".product.card")
      card.find(".item-name a").attr('href')

  attachToRelatedProducts: ->
    @_openModalOrPage @related, (node) -> node.find(".product-image").data('link')
