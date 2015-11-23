module DeviseHelper
  def devise_error_messages!
    return unless error_message

    html = <<-HTML
    <div class="alert alert-sm alert-border-left alert-#{error_class} alert-dismissable">
      <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
      <strong>#{error_message}</strong> #{error_detail ? error_detail : ""}
    </div>
    HTML

    html.html_safe
  end

  private

  def resource_error?
    resource.errors.any?
  end

  def error_message
    return "You need to sign in or sign up before continuing." if unauthorized?
    return resource.errors.full_messages.first if resource_error?
    return flash.first.last if flash.any?
    return
  end

  def error_detail
    case
    when error_message =~ /invalid.*password/i
      "<br/>" + link_to("You can reset your password here.", new_user_password_path, class: "alert-link")
    when error_message =~ /confirm.*email/i
      link_to "Didn't receive confirmation email?", new_user_confirmation_path, class: "alert-link"
    end
  end

  def error_type
    return :alert if unauthorized? or resource_error?
    flash.first.first.to_sym
  end

  def error_class
    case error_type
    when :alert   then :danger
    when :notice  then :info
    else error_type
    end
  end

  def unauthorized?
    params.has_key?("unauthorized")
  end
end
