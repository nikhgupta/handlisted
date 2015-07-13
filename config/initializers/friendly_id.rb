# Default configuration with comments can be viewed at following URL:
# https://github.com/norman/friendly_id/blob/master/lib/friendly_id/initializer.rb
FriendlyId.defaults do |config|
  config.use [:history, :finders, :slugged, :reserved]
  config.reserved_words = %w(
    new edit index session login logout users
    admin stylesheets assets javascripts images
  )
end
