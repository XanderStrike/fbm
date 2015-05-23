# fbm

Parses Facebook Message backups into a mysql database. Also provides a script to create handy charts based on your chatting habits.

## usage

Install the required gemes with `bundle install`. Make sure you have mysql and imagemagick installed first. Nokogiri can cause some problems occasionally, google the error you get and you'll be fine.

**Parsing to Database**

Create a mysql database called `fb_messages` (or modify the script to use whatever database you'd like).

Run `ruby db_populator.rb`

Your messages will now be in a simple table called `messages`. It's pretty quick, with mysql backed by innodb my 100k messages took a bit under a minute. Run some queries, it's neat.

**Generating Charts**

In `chartmaker.rb`, set the `MYNAME` constant to be your Facebook name. Run with `ruby chartmaker.rb`, it will create the graphs in the `images` directory.

## license

MIT

## contributing

Sure why not.
