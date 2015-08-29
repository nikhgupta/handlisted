$ ->

  # One way binding to display profile url
  username_field = $('input#user_username')
  url_field  = $('.section.profile-info-text .url span')
  if url_field.length and username_field.length
    username_field.on "keyup", ->
      value = username_field.val().trim().replace(/[^a-z0-9]/ig, '')
      value = '...' if value.length < 4
      url_field.html(value)

  # Display missing avatar instead of broken avatar images
  $('.user.mini-card img, img.avatar').one 'error', -> @src = "/images/avatars/missing.jpg"
