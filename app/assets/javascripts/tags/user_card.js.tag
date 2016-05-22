<user-card>
  <div id="user-{ user.id}" class="user card {primary: primary}">
    <a href='/{user.username}' class="card-on-hover">
      <img src='{ avatar }' class="img-responsive media-object avatar"/>
    </a>
  </div>

  <script type="text/coffee">
    @user = opts.user
    @primary = opts.primary || @user.primary?
    @avatar = if @user.image then @user.image else "/images/avatars/missing.jpg"
  </script>
</user-card>
