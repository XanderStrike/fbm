# fbm - db_populator
#  alex standke
#  may 2015
#
# scrapes a facebook message backup into a mysql table
#
# it ain't pretty but it works

require 'mysql2'
require 'nokogiri'
require 'time'


puts 'Creating DB'

client = Mysql2::Client.new(host: 'localhost', username: 'root', database: 'fb_messages')
client.query('DROP TABLE messages') rescue nil
client.query(<<-SQL
  CREATE TABLE messages (
    id INT(14) PRIMARY KEY,
    user VARCHAR(30),
    time TIMESTAMP,
    thread varchar(256),
    message TEXT)
  SQL
  )


puts 'Parsing HTML'

f = File.open('messages.htm')
doc = Nokogiri::HTML(f)
f.close


puts 'Storing Messages in DB'

index = 0
threads = doc.css('.thread')
threads.each do |thread|
  participants = thread.children.first.text


  puts "Processing thread: #{ participants[0..55] }..."

  messages = thread.css(".message")
  messages.each do |message|


    print "Storing message #{index}\r"

    insert_query = <<-SQL
    INSERT INTO messages (id, user, time, message, thread)
    VALUES (
      #{ index },
      '#{ client.escape(message.css(".user").text) }',
      '#{ Time.parse(message.css(".meta").text).to_s }',
      '#{ client.escape(message.next_element.text) }',
      '#{ participants }')
    SQL

    client.query(insert_query)
    index += 1
  end
  print "\r\e[A\r\e[K"
end
puts "\n\nDone."
