AWS spot script
===============

Quickly and easily spin up an aws spot instance for some processing, then kill it.  I use these scripts for stitching together images from my gopro to create time lapse videos.

Usage
-----

Copy `aws_conf.rb.example` to `aws_conf.rb` and fill it in with your aws credentials and desired instance details.

Install the `aws_sdk` gem: `sudo gem instal aws_sdk`

Then run `ruby get_spot.rb` to spin up your instance.  It creates a file to store instance information, so if it crashes you can just run it again and it'l pick up from where it left off.  When the script is done it'l tell you the ec2 hostname for you to ssh into the box.

When you're done, just run `ruby kill_spot.rb` and it'l tear down your instance and spot request.
