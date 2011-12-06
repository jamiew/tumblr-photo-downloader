require 'rubygems'
require 'bundler'
Bundler.require

site = ARGV[0]

if site.nil? || site.empty?
  puts
  puts "Usage: #{File.basename(__FILE__)} [jamiew]"
  puts
  puts "(assuming your Tumblr blog is 'jamiew.tumblr.com')"
  puts
  exit 1
end

concurrency = 8
num = 50
start = 0

puts "Downloading photos from #{site}.tumblr.com using #{concurrency} threads ..."
dir = "#{site}.tumblr.com"
FileUtils.mkdir_p(dir)

loop do
  url = "http://#{site}.tumblr.com/api/read?type=photo&num=#{num}&start=#{start}"
  page = Mechanize.new.get(url)
  doc = Nokogiri::XML.parse(page.body)

  images = (doc/'post photo-url').select{|x| x if x['max-width'].to_i == 1280 }
  image_urls = images.map {|x| x.content }

  image_urls.each_slice(concurrency).each do |group|
    threads = []
    group.each do |url|
      threads << Thread.new {
        puts "Saving photo #{url}"
        begin
          file = Mechanize.new.get(url)
          filename = File.basename(file.uri.to_s.split('?')[0])
          file.save_as("#{dir}/#{filename}")
        rescue Mechanize::ResponseCodeError
          puts "Error getting file, #{$!}"
        end
      }
    end
    threads.each{|t| t.join }
  end

  puts "#{images.count} images found (num=#{num})"
  if images.count < num
    puts "Our work here is done"
    break
  else
    start += num
  end

end
