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
    message TEXT)
  SQL
  )

puts 'Parsing HTML'
f = File.open('messages.htm')
doc = Nokogiri::HTML(f)
f.close

puts 'Storing Messages in DB'
messages = doc.css(".message")
count = messages.count
messages.each_with_index do |message, index|
  print "Storing message #{index} of #{count}\r"
  # puts "#{index} #{message.css(".user").text}: #{message.css(".meta").text}"
  # puts message.next_element.text
  client.query(<<-SQL
  INSERT INTO messages (id, user, time, message)
  VALUES (
    #{ index },
    '#{ client.escape(message.css(".user").text) }',
    '#{ Time.parse(message.css(".meta").text).to_s }',
    '#{ client.escape(message.next_element.text) }')
  SQL
  )
end

puts "\nDone."
