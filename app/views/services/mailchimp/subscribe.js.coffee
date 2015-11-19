container = $(".subscription-form")
container.find("form").fadeOut ->
  html = "
    <div class='subscriptionStatus'>
      <p>
        Thank you for subscribing with us!<br/>
        Please, confirm your subscription by clicking on the confirmation link sent to <strong><%= @email %></strong>!
      </p>
    </div>
  "
  container.find(".panel").append html
  container.find('.subscriptionStatus').fadeIn()
