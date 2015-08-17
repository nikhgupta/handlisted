$ ->

  # One way binding to display profile url
  username_field = $('input#user_username')
  url_field  = $('.section.profile-info-text .url span')
  if url_field.length and username_field.length
    username_field.on "keyup", ->
      value = username_field.val()
      value = '...' if value is ''
      url_field.html(value)

