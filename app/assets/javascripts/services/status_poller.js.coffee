class @StatusPoller
  constructor: (@options) ->
    @timer = null

  init: ->
    @timer = setInterval (=> @getJobStatus()), 1000

  getJobStatus: ->
    $.post "/products/create/status.json", { job_id: @options.job_id }, (response) =>
      console.log response
      if response.status in ["Queued", "Working"]
        @options.onTick(response)
      else
        clearInterval(@timer)
        @options.onComplete(response)
