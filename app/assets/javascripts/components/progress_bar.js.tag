<progress-bar>
  <div class="progress">
    <div class="progress-bar progress-bar-{status}" style="width:{current_progress}%"
      aria-valuenow="{current_progress}" aria-valuemin="0" aria-valuemax="100">
      <span if={show_progress}>{current_progress}%</span>
    </div>
  </div>

  <script type="text/coffee">
    @statusMap = { queued: "master", working: "primary", complete: "success", failed: "danger", "": "default" }
    @updateBar = (options) => @[key] = val for key, val of options; @update(); @
    @updateBar status: "default", show_progress: false, current_progress: (opts.initial || 0)

    @reset           = => @updateBar status: "", current_progress: 0
    @finished        = => @setProgress(100)
    @setProgress = (x) => @updateBar(current_progress: x)
    @increment   = (x) => @setProgress(@current_progress + (x || 1))
    @setMinimumAndIncrement = (min, inc) =>
      if @current_progress < min then @setProgress(min) else @increment(inc)

    @setStatus = (status) =>
      options = { status: @statusMap[status] }
      $.extend(options, current_progress: 100) unless status in ["queued", "working"]
      @updateBar options; @

  </script>
</progress-bar>
