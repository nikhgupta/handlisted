class DeviseMailerPreview < ActionMailer::Preview
  def confirmation_instructions()
    DeviseBackgroundMailer.confirmation_instructions(previewer, "some-token", {})
  end

  def reset_password_instructions
    DeviseBackgroundMailer.reset_password_instructions(previewer, "some-token", {})
  end

  # def unlock_instructions
  #   DeviseBackgroundMailer.unlock_instructions(previewer, "some-token", {})
  # end

  private

  def previewer
    email = "previewer@example.com"
    user  = User.find_by(email: email)
    return user if user.try :persisted?
    FactoryGirl.create(:user, email: email)
  end
end
