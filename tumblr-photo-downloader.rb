require 'rubygems'
require 'bundler'
Bundler.require


# Your Tumblr subdomain, e.g. "jamiew" for "jamiew.tumblr.com"
site = "doctorwho"


FileUtils.mkdir_p(site)

concurrency = 8
num = 50
start = 0

loop do
  puts "start=#{start}"

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
          file.save_as("#{site}/#{filename}")
        rescue Mechanize::ResponseCodeError
          puts "Error getting file, #{$!}"
        end
      }
    end
    threads.each{|t| t.join }
  end

  puts "#{images.count} images found (num=#{num})"
  if images.count < num
    puts "our work here is done"
    break
  else
    start += num
  end

end
