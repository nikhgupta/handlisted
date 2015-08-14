puts "Seeding.."
raise 'You must supply DEFAULT_PASSWORD environment variable.' if ENV['DEFAULT_PASSWORD'].blank?

if Rails.env.development?
  puts 'Creating test users for development...'
  %w[test admin].each do |id|
    user = User.find_or_initialize_by(email: "#{id}@example.com", name: "#{id.titleize} User")
    user.skip_confirmation!
    user.password = user.password_confirmation = ENV['DEFAULT_PASSWORD']
    user.admin = id == "admin"
    user.save
  end
end

fake_users = []

if File.exists?('scripts/personnas.yml')
  YAML.load_file('scripts/personnas.yml').each do |country, people|
    puts "Creating user personnas for country: #{country.titleize}! Found #{people.count} personna(s)."
    people.map { |p| p.split(",").map(&:strip) }.each do |person|
      email  = "#{person[1].gsub(' ', '.')}@noop.com".downcase
      gender = (person[2].to_i > 0 ? :female : :male)

      user = User.find_by(email: email)
      if user.present?
        fake_users << user.id
        next
      else
        user = User.new(email: email, name: person[1], fake_personna: true, gender: gender)
        user.password = user.password_confirmation = ENV['DEFAULT_PASSWORD']
        user.image = "https://s3.amazonaws.com/uifaces/faces/twitter/#{person[0]}/128.jpg"
        user.skip_confirmation!
        fake_users << user.id if user.save
      end
    end
  end
end

# simulate finding of products
if File.exists?('scripts/products.yml')
  data = YAML.load_file('scripts/products.yml')
  puts "Importing #{data["products"].count} products..."
  data["products"].each do |url|
    begin
      ProductScraperJob.new.perform(fake_users.sample, url)
    rescue StandardError => e
      puts "[ERROR #{e.class}]: #{e.message}\n- while importing product: #{url}"
    end
  end
end

# simulate liking of products
products = Product.all
puts "Simulating user like behaviour..."
fake_users.each do |user_id|
  total = (Product.count/10) + rand(Product.count/2)
  user = User.find(user_id)
  products.shuffle.take(total).each do |product|
    user.like(product)
  end
end
