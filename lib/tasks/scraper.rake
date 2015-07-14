namespace :scraper do

  def nicer_backtrace(error, options = {})
    bt = error.backtrace.map do |x|
      x.match(/^(.+?):(\d+)(|:in `(.+)')$/);
      file, line, message = $1,$2,$4
      file = "CURRENT_FILE" if file == __FILE__
      file = file.gsub("#{Bundler.bundle_path}/", 'LIBPATH: ')
      file = file.gsub(/LIBPATH: gems\/(.*?)-((\d\.?)*)\/(.*)$/, 'GEM[\1]: \4')
      "#{"%03d" % line}: #{file} :: #{message}"
    end
    return bt unless options[:lines] || options[:current_file]

    current = bt.select{|a| a.include?("CURRENT_FILE")}
    bt = options[:lines] ? bt.first(options[:lines]) : []
    [ bt, current ].flatten.uniq
  end
  task canopy: :environment do
    agent = Mechanize.new{|a| a.user_agent_alias = 'Mac Safari'}
    provider = Provider.find_or_create_by(name: "Amazon")
    user = User.first
    (1..20000).to_a.shuffle.each do |i|
      begin
        url  = "https://canopy.co/product/#{i}"
        page = agent.get url
        data = page.search("[data-react-class='ProductDetailsActions']")
        if data.empty?
          puts "Product with Canopy ID: #{"%05d" % i} has since been removed."
          next
        end
        data = JSON.parse(data.attr("data-react-props").value)
        data = data["product"]
        data = {
          user: user,
          brand_name: data["brand_name"],
          name: data["name_without_brand"],
          original_name: data["name"],
          priority_service: data["prime"],
          note: data["editors_note"],
          available: data["available"],
          pid: data["asin"],
          images: ["https:#{data.delete("image")}"],
          price: (data['price'] ? data["price"].to_money : 0)
        }

        if provider.products.where(pid: data[:pid]).exists?
          puts "Already found Product with Canopy ID: #{"%05d" % i}"
        else
          provider.products.create data
          puts "Scraped Product with Canopy ID: #{"%05d" % i}"
        end
      rescue StandardError => e
        puts
        puts "-" * 80
        puts "Unable to scrape product with Canopy ID: #{"%05d" % i}"
        puts "[Error]: #{e.message}"
        puts nicer_backtrace(e, lines: 5, current_file: true)
        puts "-" * 80
        puts
        # binding.pry
      end
    end
  end
end
