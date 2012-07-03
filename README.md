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

Enjoy!



License
-------

Source code released under an [MIT license](http://en.wikipedia.org/wiki/MIT_License)

Pull requests welcome.


Authors
-------

* [Jamie Wilkinson](http://jamiedubs.com) ([@jamiew](http://github.com/jamiew))


