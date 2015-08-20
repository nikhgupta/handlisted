# Use this hook to configure merit parameters
Merit.setup do |config|
  # Check rules on each request or in background
  config.checks_on_each_request = true

  # Define ORM. Could be :active_record (default) and :mongoid
  config.orm = :active_record

  # Add application observers to get notifications when reputation changes.
  # config.add_observer 'MyObserverClassName'

  # Define :user_model_name. This model will be used to grand badge if no
  # `:to` option is given. Default is 'User'.
  config.user_model_name = 'User'

  # Define :current_user_method. Similar to previous option. It will be used
  # to retrieve :user_model_name object if no `:to` option is given. Default
  # is "current_#{user_model_name.downcase}".
  config.current_user_method = 'current_user'
end

# Create application badges (uses https://github.com/norman/ambry)
badge_id = 0
data = YAML.load_file(Rails.root.join("config", "badges.yml"))

data.each do |category_data|
  category_data.each_pair do |category, badges|
    badges.each do |badge|
      badge_id += 1
      attrs = %w[name level description].map do |field|
        [field.to_sym, badge.delete(field)]
      end
      badge = badge.merge(category: category)
      attrs = { id: badge_id, custom_fields: badge }.merge(Hash[attrs])
      Merit::Badge.create! attrs
    end
  end
end
