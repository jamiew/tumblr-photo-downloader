require 'rubygems'
require 'bundler'
Bundler.require

def job_done()
  # print status and exit
  puts "Skipped #{$already_had} existing photos."
  puts "Downloaded #{$new_images} new photos."
  if $image_limit
    puts $image_limit > $new_images ? "Failed to download #{$image_limit - $new_images} photos." : "All requested photos have been downloaded."
  end
  puts "Done."
  exit
end

site = ARGV[0]
directory = ARGV[1] ? ARGV[1] : site
fullbackup = ARGV[2] ? "fullbackup" == ARGV[2] : false
$image_limit = ARGV[3] ? ARGV[3].to_i : 0

if ARGV.empty?
  puts
  puts "Usage: #{File.basename(__FILE__)} URL [directory to save in] [fullbackup] [image limit]"
  puts "eg. #{File.basename(__FILE__)} jamiew.tumblr.com"
  puts "eg. #{File.basename(__FILE__)} jamiew.tumblr.com ~/pictures/jamiew-tumblr-images/"
  puts "eg. #{File.basename(__FILE__)} jamiew.tumblr.com ~/pictures/jamiew-tumblr-images/ fullbackup"
  puts "eg. #{File.basename(__FILE__)} jamiew.tumblr.com ~/pictures/jamiew-tumblr-images/ fullbackup 400"
  puts
  exit 1
end

concurrency = 8

puts "Downloading photos from #{site.inspect}, concurrency=#{concurrency} ..."
FileUtils.mkdir_p(directory)

num = 50
start = 0
$new_images = 0
$already_had = 0

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
  puts "Found #{images.count} photos (page size = #{num})"
  image_urls = images.map {|x| x.content }

  done_images = 0

  image_urls.each_slice(concurrency).each do |group|
    threads = []
    group.each do |url|
      threads << Thread.new {
        begin
          filename = url.split("/").last
          if File.exists?("#{directory}/#{filename}")
            puts "Already have #{url}\n"
            $already_had += 1
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
            $new_images += 1

            if $new_images == $image_limit
              # reached image limit
              job_done()
            end
          end

          done_images += 1

        rescue Mechanize::ResponseCodeError
          puts "Error getting file, #{$!}\n"
        end
      }
    end
    threads.each{|t| t.join }
  end

  if images.count == done_images
    # processed (downloaded or skipped) all found images
    if fullbackup && images.count > 0
      # doing full backup and not yet reached the end of tumblr archive
      start += num
      # continue the main loop
    else
      job_done() # exits script
    end
  end
end
