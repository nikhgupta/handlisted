%w[extractor].each do |dir|
  pattern = Rails.root.join('lib', dir, '**', '*.rb')
  Dir.glob(pattern).each{|file| require file}
end

