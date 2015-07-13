puts "Seeding.."

User.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password', name: "Test User")
User.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password', admin: true, name: "Admin User")
# exec("rake scraper:canopy")
