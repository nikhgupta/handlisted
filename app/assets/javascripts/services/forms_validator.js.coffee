# Run validations on all forms inside the given selector.
# This validator is designed for `.admin-form` forms.
#
# Also, adds an `allowed` validator to validate input against given regex.
#
class @FormsValidator
  constructor: (selector, @options = {}) -> @selector = $(selector)

  validatorOptions:
    onfocusout: (element, event) -> $(element).valid()
    highlight: (element, errorClass, validClass) ->
      $(element).closest('.field').addClass(errorClass).removeClass validClass
    unhighlight: (element, errorClass, validClass) ->
      $(element).closest('.field').removeClass(errorClass).addClass validClass
    errorPlacement: (error, element) ->
      if element.parents().has(".input-footer .error").length
        error_el = element.parents().find(".input-footer .error")
        error_el.replaceWith(error).promise().done -> error_el.show()
      else if element.is(':radio') or element.is(':checkbox')
        element.closest('.option-group').after error
      else error.insertAfter element.parent()

  init: ->
    $.validator.addMethod 'allowed', ((value, element, params) ->
      # allow any non-whitespace characters as the host part
      regex  = ''
      regex += '0-9'    if params.match /number/
      regex += 'a-z'    if params.match /lowercase/
      regex += 'A-Z'    if params.match /uppercase/
      regex += 'a-zA-Z' if params.match /alphabet/
      regex  = new RegExp("^[#{regex}]+$")
      @optional(element) or regex.test(value)
    ), 'Please enter a valid value with <strong>{0}</strong> only.'

    options = $.extend(@options, @validatorOptions)
    @selector.each -> $(@).validate options
