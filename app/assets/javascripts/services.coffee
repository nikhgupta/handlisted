#= require services/magnific_modal
#= require services/forms_validator
#= require services/newsletter_subscriber

ready = ->
  # validate all forms on this page using services/form_validator
  new FormsValidator(
    '.admin-form form, form.admin-form',
    errorClass: 'state-error', validClass: 'state-success', errorElement: "em"
  ).init()

$(document).ready(ready)
$(document).on('pages:load', ready)
