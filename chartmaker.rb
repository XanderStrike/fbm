# fbm - chartmaker
#  alex standke
#  may 2015
#
# generates charts based on databased facebook messages

require 'mysql2'
require 'gruff'


# -- settings --

THEME = Gruff::Themes::RAILS_KEYNOTE
MYNAME = 'Alexander Standke'


# -- mysql --

client = Mysql2::Client.new(host: 'localhost', username: 'root', database: 'fb_messages')


# -- simple grunt initializer service --

class G
  class << self
    def init_line title
      init(Gruff::Line, title)
    end

    def init_dot title
      init(Gruff::Dot, title)
    end

    def init_area title
      init(Gruff::Area, title, hide_legend: true)
    end

    def init_bar title
      init(Gruff::Bar, title, hide_legend: true)
    end

    private

    def init klass, title, size: 1000, hide_legend: false
      g = klass.new(size)
      g.title = title
      g.theme = THEME
      g.hide_legend = hide_legend
      g
    end
  end
end


# -- data massaging --

def data_from_num g, results
  formatted_data = results.map { |r| r['num'] }
  g.data('Messages', formatted_data)
  g.minimum_value = 0
  g.maximum_value = formatted_data.max
  g
end

def number_labels num, multiplier=1
  {}.tap do |labels|
    num.times do |x|
      labels[(x * multiplier)] = (x * multiplier).to_s
    end
  end
end


# -- charts --

def by_hour client
  results = client.query('SELECT HOUR(time) as hour, COUNT(1) as num FROM messages GROUP BY HOUR(time)').to_a

  g = G.init_area 'Messages by Hour of Day'
  g.labels = number_labels(24)

  g = data_from_num(g, results)

  g.write('images/by_hour.png')
end

by_hour client


def by_day_of_week client
  results = client.query('SELECT DAYOFWEEK(time) as day, COUNT(1) as num FROM messages GROUP BY DAYOFWEEK(time)').to_a

  g = G.init_bar 'Messages by Day of Week'

  g.labels = {}.tap do |h|
    %w(Sun Mon Tue Wed Thu Fri Sat).each_with_index do |day, i|
      h[i] = day
    end
  end

  g = data_from_num(g, results)

  g.write('images/by_day_of_week.png')
end

by_day_of_week client


def top_conversations client
  results = client.query('select thread, count(1) as num from messages group by thread order by num desc limit 20').to_a

  g = G.init_bar 'Top 20 Conversations'
  g.x_axis_label = 'Initial of Users(s)'
  g.label_max_size = 4
  g.marker_font_size = 10

  g.labels = {}.tap do |labels|
    20.times do |x|
      anonymized_name = results[x]['thread'].split(', ').reject{|n| n == MYNAME}.map {|r| r[0]}.join('')
      labels[x] = anonymized_name
    end
  end

  g = data_from_num(g, results)

  g.write('images/top_conversations.png')
end

top_conversations client


def message_length client
  results = client.query('select length(message) as length, count(1) as num from messages group by length limit 150')
  average = client.query('select avg(length(message)) as average from messages').to_a[0]["average"].to_f
  max = client.query('select max(length(message)) as average from messages').to_a[0]["average"].to_i

  g = G.init_area 'Message Length'
  g.x_axis_label = "Max: #{ max }  Average: #{ average }"

  g.labels = number_labels(15, 10)

  g = data_from_num(g, results)

  g.write('images/message_length.png')
end

message_length client
