namespace :verify do
  desc 'find blank or placeholder links on website'
  task :placeholder_links do
    host, agent = "localhost:12000", Mechanize.new
    agent.add_auth "http://#{host}", ENV['ALPHA_USER'], ENV['ALPHA_PASS']
    links = ["http://#{host}"]
    visited = []

    while links.any?
      begin
        page = nil
        begin
          visited.push links.shift
          page = agent.get visited.last
        rescue Mechanize::ResponseCodeError => e
          puts "#{e.response_code}: #{e.page.uri}"
        end
        next unless page && page.respond_to?(:links)

        page.links.select do |link|
          link.href.to_s.gsub(/^\#+$/, '').empty?
        end.each do |link|
          puts "#{link.text.strip} - #{page.uri.to_s}"
        end

        links |= page.links.map(&:href)
        links  = links.reject{|link| link.to_s.gsub(/^\#+$/, '').empty? }.uniq
        links  = links.map{|link| link.start_with?("/") ? "http://#{host}#{link}" : link}
        links  = links.select{|link| URI.parse(link).host == URI.parse("http://#{host}").host}.uniq
        links  = links.reject{|link| %w[go like].detect{|a| link.end_with?(a)}}
        links  = links - visited
      end
    end
  end
end
