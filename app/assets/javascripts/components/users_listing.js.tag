<users-listing>
  <div class="row users list">
    <user-card user={item} each={item in users}></user-card>
    <div if="{ counter > 0}" class="user card"><span>+{ counter }</span></div>
  </div>

  <script type="text/coffee">
    @founder   = $.extend(false, opts.primary, primary: true)
    @all_users = opts.users || []

    @updateListing = =>
      unique = {}
      unique[x.id] = x for x in @all_users when x.id != @founder.id
      @all_users = (value for key, value of unique)
      @counter   = @all_users.length - 9
      @users     = $.merge [@founder], @all_users.slice(0, 9)
      @update()

    @loadUsersFromUrl = (url) ->
      $.get url, (response) =>
        $.merge @all_users, response
        @updateListing()

    @on 'mount', =>
      @updateListing()
      (@loadUsersFromUrl(opts.url) if opts.url?) unless opts.users?.length > 0

  </script>
</users-listing>
