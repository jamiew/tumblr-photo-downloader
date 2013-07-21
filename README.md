Tumblr Photo Downloader
=======================

Ruby script to download all the photos from a Tumblr blog.

Tumblr also has a GUI backup tool for Mac, [Tumblr Backup.app](http://staff.tumblr.com/post/286303145/tumblr-backup-mac-beta)


Usage
-----

Checkout the code:

    git clone git://github.com/jamiew/tumblr-photo-downloader.git
    cd tumblr-photo-downloader

Install bundler:

    gem install bundler
    bundle install

Run the script, specifying your blog URL as the argument:

    ruby tumblr-photo-downloader.rb jamiew.tumblr.com

By default, images will be saved in a sub-directory of the directory containing the script (eg tumblr-photo-downloader/jamiew.tumblr.com). If you want them to be saved to a different directory, you can pass its name as an optional second argument:

    ruby tumblr-photo-downloader.rb jamiew.tumblr.com ~/pictures/jamiew-tumblr-images/

If you have run the script previously, specifying the same Tumblr URL and destination directory, then it will stop after sequentially encountering links to 50 images that have been previously downloaded.

If you want to download all the images from the blog you can specify "fullbackup" as the optional third argument. Additionally, you can set a limit of maximum number of images you want the script to download, as the optional fourth argument:

    ruby tumblr-photo-downloader.rb jamiew.tumblr.com ~/pictures/jamiew-tumblr-images/ fullbackup

or:

    ruby tumblr-photo-downloader.rb jamiew.tumblr.com ~/pictures/jamiew-tumblr-images/ fullbackup 400

Enjoy!



License
-------

Source code released under an [MIT license](http://en.wikipedia.org/wiki/MIT_License)

Pull requests welcome.


Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


Authors
-------

* [Jamie Wilkinson](http://jamiedubs.com) ([@jamiew](https://github.com/jamiew))
* [James Scott-Brown](http://jamesscottbrown.com/) ([@jamesscottbrown](https://github.com/jamesscottbrown))


