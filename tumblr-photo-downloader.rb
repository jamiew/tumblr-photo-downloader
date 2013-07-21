require 'rubygems'
require 'bundler'
Bundler.require

site = ARGV[0]
directory = ARGV[1] ? ARGV[1] : site

if site.nil? || site.empty?
  puts
  puts "Usage: #{File.basename(__FILE__)} URL [directory to save in]"
  puts "eg. #{File.basename(__FILE__)} jamiew.tumblr.com"
  puts "eg. #{File.basename(__FILE__)} jamiew.tumblr.com ~/pictures/jamiew-tumblr-images/"
  puts
  exit 1
end

concurrency = 8

puts "Downloading photos from #{site.inspect}, concurrency=#{concurrency} ..."
FileUtils.mkdir_p(directory)

num = 50
start = 0

loop do
  url = "http://#{site}/api/read?type=photo&num=#{num}&start=#{start}"
  begin
    puts "Getting new page..."
    page = Mechanize.new.get(url)
  rescue
    puts "Error getting new page from tumblr."
    puts "Retrying..."
    retry
  end
  doc = Nokogiri::XML.parse(page.body)

  images = (doc/'post photo-url').select{|x| x if x['max-width'].to_i == 1280 }
  image_urls = images.map {|x| x.content }

  already_had = 0

  image_urls.each_slice(concurrency).each do |group|
    threads = []
    group.each do |url|
      threads << Thread.new {
        begin
          filename = url.split("/").last
          if File.exists?("#{directory}/#{filename}")
            puts "Already have #{url}\n"
            already_had += 1
          else
            begin
              file = Mechanize.new.get(url)
            rescue Exception
              puts "Error getting photo #{url}\n"
              puts "Retrying...\n"
              retry
            end
            puts "Saving photo #{filename}\n"
            file.save_as("#{directory}/#{filename}")
          end

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
  elsif already_had == num
    puts "Had already downloaded the last #{already_had} of #{num} most recent images - done."
    break
    else
    start += num
  end

end
