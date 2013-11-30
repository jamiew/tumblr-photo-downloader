require 'rubygems'
require 'bundler'
require 'digest/md5'
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

# Create a log directory
logs = [directory, 'logs'].join('/')
FileUtils.mkdir_p(logs)

num = 50
start = 0

puts "Downloading photos from #{site.inspect}, concurrency=#{concurrency} ..."

loop do
  url = "http://#{site}/api/read?type=photo&num=#{num}&start=#{start}"
  page = Mechanize.new.get(url)

  doc = Nokogiri::XML.parse(page.body)
  md5 = Digest::MD5.hexdigest(doc.to_s)

  # Log the content that we are getting
  File.open([logs, md5].join('/'), 'w') { | f |
    f.write(doc.to_s)
  }

  images = (doc/'post photo-url').select{|x| x if x['max-width'].to_i == 1280 }
  image_urls = images.map {|x| x.content }

  already_had = 0

  image_urls.each_slice(concurrency).each do |group|
    threads = []
    group.each do |url|
      threads << Thread.new {
        begin
          file = Mechanize.new.get(url)
          filename = File.basename(file.uri.to_s.split('?')[0])

          if File.exists?("#{directory}/#{filename}")
            puts "Already have #{url}"
            already_had += 1
          else
            puts "Saving photo #{url}"
            file.save_as("#{directory}/#{filename}")
          end

        rescue
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
