# Class for dealing with submissions for adding a new product via sitewide
# search bar in the header. This class does the following:
#
# - allows user to add a new query for submission.
# - checks if the query is a URL for importing a product or a search.
# - redirects to search results if query is search.
# - imports the product while showing the user relevant progress if importing.
#
class @ProductAdder
  constructor: (@options) ->
    @form  = $(@options.form)
    @timer = null
    @jobid = null

  setup: ->
    return false unless @form?
    @input       = @form.find(@options.input)
    @endpoints   = @options.endpoints
    @progressbar = @form.find('.progress-bar')
    return true

  init: ->
    return unless @setup()

    @input.on 'blur', =>
      @input.val(@options.default_input_text) if @input.val() is ""

    @input.on 'focus', =>
      @input.val("") if @input.val() is @options.default_input_text

    @form.on 'submit', (e) =>
      e.preventDefault()
      $.post @endpoints.check, { search: @input.val() }, (response) =>
        if response.valid and response.existing?
          window.location = response.existing
        else if response.valid
          @import @input.val()
        else
          @form.unbind('submit')
          @form.submit()

  import: (url, job_id = null) ->
    @switchToProgressBar()
    if job_id
      @jobid = job_id
      @timer = setInterval (=> @getJobStatus()), 1000
    else
      $.post @endpoints.add, { url: url }, (response) =>
        @jobid = response.id
        @timer = setInterval (=> @getJobStatus()), 1000

  getJobStatus: ->
    $.post @endpoints.status, { job_id: @jobid }, (response) =>
      @status = response
      @progressbar.html(response.status)
      @updateProgressBarStyle()
      @updateProgressBarValue()
      @clearTimerIfComplete()
      @takeActionForCurrentStatus()
      @response = null

  takeActionForCurrentStatus: ->
    if @status.status in ["", "Failed"]
      @displayErrors(@status.error_html)
    else if @status.id?
      setInterval (=> window.location = "/products/#{@status.id}"), 800

  displayErrors: (errors) ->
    new MagnificModal
      html: errors
      modalClass: "product-adder-errors"
      animation: "slideDown"
      callbacks: beforeClose: (e) => @switchToSearchForm()
    .open()

  clearTimerIfComplete: ->
    clearInterval(@timer) if @status.status not in ["Queued", "Working"]

  updateProgressBarStyle: ->
    @progressbar.removeClass 'progress-bar-dark progress-bar-default'
    @progressbar.removeClass 'progress-bar-warning progress-bar-success progress-bar-danger'
    @progressbar.addClass "progress-bar-#{@style_map[@status.status]}"

  updateProgressBarValue: ->
    value = 10  if @status.status == 'Queued'
    value = 70  if @status.status == 'Working'
    value = 100 unless value
    current_value = parseInt(@progressbar.attr("aria-valuenow"))
    value = current_value + 1 if value <= current_value
    value = current_value if value < current_value and current_value < value * 2
    @progressbar.css('width', "#{value}%").attr("aria-valuenow", value)

  switchToProgressBar: ->
    width = @form.find('.form-group').width()
    @resetProgressBar()
    @form.find('.progress').css('width', width)
    @form.find('.form-group').hide()
    @form.find('.progress').show()

  switchToSearchForm: ->
    width = @form.find('.progress').width()
    @form.find('.form-group input').css('width', width)
    @form.find('.progress').hide()
    @form.find('.form-group').show()

  resetProgressBar: ->
    @progressbar.css('width', "0%").attr("aria-valuenow", 0).html("")
    @progressbar.removeClass 'progress-bar-default progress-bar-warning progress-bar-success progress-bar-danger'
    @progressbar.addClass 'progress-bar-dark'
    @form.removeData("job-id").removeAttr("data-job-id")

  style_map:
    "": "default",
    "Queued": "dark",
    "Working": "warning",
    "Complete": "success",
    "Failed": "danger",
