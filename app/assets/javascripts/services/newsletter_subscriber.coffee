class @NewsletterSubscriber
  constructor: (el) -> @el = $(el)

  html: (email) -> "
    <div class='subscriptionStatus'>
      <p>
        Thank you for subscribing with us!<br/>
        Please, confirm your subscription by clicking on the confirmation link sent to <strong>#{email}</strong>!
      </p>
    </div>
  "

  subscribe: (email) ->
    @el.find("form").after @html(email)
    @el.find("form").fadeOut => @el.find(".subscriptionStatus").fadeIn()
