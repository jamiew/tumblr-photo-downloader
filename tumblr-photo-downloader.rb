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

# Create log with md5 hashes of pages we've visited
logs = [directory, 'logs'].join('/')
FileUtils.mkdir_p(logs)

num = 50
start = 0

puts "Downloading photos from #{site.inspect}, concurrency=#{concurrency} ..."

loop do
  url = "http://#{site}/api/read?type=photo&num=#{num}&start=#{start}"
  page = Mechanize.new.get(url)

  page = Nokogiri::XML.parse(page.body)
  md5 = Digest::MD5.hexdigest(page.to_s)

  # Log the content that we are getting
  puts "#{url} => #{[logs, md5].join('/')}"
  File.open([logs, md5].join('/'), 'w') { | f |
    f.write(page.to_s)
  }

  images = (page/'post photo-url').select{|x| x if x['max-width'].to_i == 1280 }
  image_urls = images.map {|x| x.content }

  already_visited = 0

  image_urls.each_slice(concurrency).each do |group|
    threads = []
    group.each do |url|
      threads << Thread.new do
        begin
          filename = File.basename(url.split('?')[0])

          remote_content_length = Mechanize.new.head(url)["content-length"].to_i
          local_file_size = File.stat("#{directory}/#{filename}").size.to_i
          if File.exists?("#{directory}/#{filename}") and remote_content_length === local_file_size
            # puts "Already have #{url}"
            print '.'; $stdout.flush
            already_visited += 1
          else
            puts "Saving photo #{url}"
            file = Mechanize.new.get(url)
            file.save_as("#{directory}/#{filename}")
          end

        rescue
          puts "Error getting file, #{$!}"
        end
      end
    end
    threads.each{|t| t.join }
  end

  puts "#{images.count} images found (num=#{num})"

  if images.count < num
    puts "Our work here is done"
    break
  elsif already_visited == num
    puts "We've already downloaded the last #{already_visited} of #{num} most recent images, stopping."
    break
  else
    start += num
  end

end
