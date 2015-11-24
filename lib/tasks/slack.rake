require 'open-uri'

namespace :slack do
  desc 'Notify slack about the coverage report from Circle-CI'
  task 'coverage' do
    if ENV['CI']
      WebMock.allow_net_connect!

      path = "#{ENV['CIRCLE_ARTIFACTS']}/coverage"
      url  = "https://circle-artifacts.com/gh/nikhgupta/handlisted.in"
      url += "/#{ENV['CIRCLE_BUILD_NUM']}/artifacts/0#{path}"

      html = Nokogiri::HTML(File.read("#{path}/index.html"))
      report   = html.search("#AllFiles div").text.gsub(/\s+/, ' ').strip
      percent  = html.search(".covered_percent")[0].text
      strength = html.search(".covered_strength")[0].text
      icon = html.search("link").detect{|a| a.attr("rel") == "shortcut icon"}

      surl = URI(ENV['SLACK_COVERAGE_URL'])
      icon = "#{url}/#{icon.attr('href')}"
      text = "<#{url}/index.html|Coverage report> for last build: #{percent}\n#{report}"
      data = { channel: "#general", username: "simplecov", icon_url: icon, text: text }

      Net::HTTP.post_form surl, payload: data.to_json
    else
      puts "This task is aimed to be used within CircleCI environment."
    end
  end
end
