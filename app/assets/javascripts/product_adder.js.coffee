class @ProductAdder
  constructor: (options) ->
    @form        = $(options.form)
    @options     = options
    @timer       = null

  setup: ->
    return false unless @form?
    @input       = @form.find(@options.input)
    @endpoints   = @options.endpoints
    @progressbar = @form.find('.progress-bar')
    @errorModal  = $('.product-adder-errors')
    return true

  init: ->
    return unless @setup()
    @form.on 'submit', (e) =>
      e.preventDefault()
      $.post @endpoints.check, { search: @input.val() }, (response) =>
        if response.valid
          @switchToProgressBar()
          $.post @endpoints.add, { url: @input.val() }, (response) =>
            @form.data "job-id", response.id
            @timer = setInterval (=> @getJobStatus()), 1000
        else
          @form.unbind('submit')
          @form.submit()

  getJobStatus: ->
    job_id = @form.data('job-id')
    $.post @endpoints.status, { job_id: job_id }, (response) =>
      @status = response
      @progressbar.html(response.status)
      @updateProgressBarStyle()
      @updateProgressBarValue()
      @clearTimerIfComplete()
      @takeActionForCurrentStatus()
      @response = null

  takeActionForCurrentStatus: ->
    if @status.status in ["Failed", ""]
      @displayErrors(@status.errors)
    else if @status.id?
      setInterval (=> window.location = "/product/#{@status.id}"), 800

  displayErrors: (errors) ->
    @errorModal.find('ul.errors').html(errors) if errors?.length > 0
    $.magnificPopup.open
      removalDelay: 500
      items:
        src: @errorModal
      callbacks:
        beforeOpen: (e) -> @st.mainClass = "mfp-slideDown"
        beforeClose: (e) => @switchToSearchForm()

      midClick: true

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
