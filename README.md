Tumblr Photo Downloader
=======================

Ruby script to download all the photos from a Tumblr blog.

Tumblr used to have a GUI backup tool for Mac OS but it appears to be unmaintained :''( [Tumblr Backup.app](http://staff.tumblr.com/post/286303145/tumblr-backup-mac-beta)


Usage
-----

Checkout the code:

    git clone https://github.com/jamiew/tumblr-photo-downloader
    cd tumblr-photo-downloader

Install bundler if you don't have it already:

    gem install bundler
    bundle install

Run the script, specifying your blog URL as the argument:

    bundle exec ruby tumblr-photo-downloader.rb jamiew.tumblr.com

By default, images will be saved in a sub-directory of the directory containing the script (eg tumblr-photo-downloader/jamiew.tumblr.com). If you want them to be saved to a different directory, you can pass its name as an optional second argument:

    bundle exec ruby tumblr-photo-downloader.rb jamiew.tumblr.com ~/pictures/jamiew-tumblr-images/

If you have run the script previously, specifying the same Tumblr URL and destination directory, then it will stop after sequentially encountering links to 50 images that have been previously downloaded.

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
* [Chris McKenzie](http://getpostdelete.com/) ([@kristopolous](https://github.com/kristopolous))
* [@zamabe](https://github.com/zamabe)


