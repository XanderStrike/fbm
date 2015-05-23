require 'mysql2'
require 'gruff'

client = Mysql2::Client.new(host: 'localhost', username: 'root', database: 'fb_messages')

THEME = Gruff::Themes::PASTEL
MYNAME = 'Alexander Standke'

def init_gruff klass, size=1000
  g = klass.new(size)
  g.theme = THEME
  g
end

# def init_gruff_line title, size=1000
#   g = Gruff::Line.new(size)
#   g.theme = THEME
#   g.title = title
#   g
# end

def init_gruff_bar title, size=1000
  g = init_gruff(Gruff::Bar)
  g.title = title
  g.hide_legend = true
  g
end

def data_from_num g, results
  formatted_data = results.map { |r| r['num'] }
  g.data('Messages', formatted_data)
  g.minimum_value = 0
  g.maximum_value = formatted_data.max
  g
end

def by_hour client
  results = client.query('SELECT HOUR(time) as hour, COUNT(1) as num FROM messages GROUP BY HOUR(time)').to_a

  g = init_gruff_bar 'Messages by Hour of Day'
  g.labels = {}.tap do |labels|
    24.times do |x|
      labels[x] = x.to_s
    end
  end

  g = data_from_num(g, results)

  g.write('images/by_hour.png')
end

def by_day_of_week client
  results = client.query('SELECT DAYOFWEEK(time) as day, COUNT(1) as num FROM messages GROUP BY DAYOFWEEK(time)').to_a

  g = init_gruff_bar 'Messages by Day of Week'

  g.labels = {
    0 => 'Sun',
    1 => 'Mon',
    2 => 'Tue',
    3 => 'Wed',
    4 => 'Thu',
    5 => 'Fri',
    6 => 'Sat',
  }

  g = data_from_num(g, results)

  g.write('images/by_day_of_week.png')
end

def top_conversations client
  results = client.query('select thread, count(1) as num from messages group by thread order by num desc limit 20').to_a

  g = init_gruff_bar 'Top 20 Conversations'
  g.label_max_size = 4
  g.marker_font_size = 10
  g.x_axis_label = 'Initial of Users(s)'

  g.labels = {}.tap do |labels|
    20.times do |x|
      anonymized_name = results[x]['thread'].split(', ').reject{|n| n == MYNAME}.map {|r| r[0]}.join('')
      labels[x] = anonymized_name
    end
  end

  g = data_from_num(g, results)

  g.write('images/top_conversations.png')
end

by_hour client
by_day_of_week client
top_conversations client

