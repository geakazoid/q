require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'stringio'
require 'mysql'

# database information
server = 'localhost'
database = 'q2012'
username = 'root'
password = 'gz209242'

# stats directory
stats_dir = '/var/rails/q2012.org/public/web'

# find out which file we'll be working on
division = ARGV[0]

# files
stats_file = stats_dir + '/' + division + '.html'
team_file = stats_dir + '/' + division + '_teamstandings.html'
ind_file = stats_dir + '/' + division + '_indstandings.html'

# names
team_name = division + '_team'
ind_name = division + '_ind'

# connect to the mysql server
dbh = Mysql.real_connect(server, username, password, database)

# create a new output buffer
buffer = StringIO.new
$stdout = buffer

# check to see if all of the files exist
# exit if they don't
unless File.exists?(team_file) and File.exists?(ind_file)
  puts "no files"
  exit
end

# find the time
t = Time.now

# find real division name
query = "select title from statistics where name = '#{division}'"
sth = dbh.prepare(query)
sth.execute
row = sth.fetch
stats_name = row[0]

# output when this was generated
#puts "<p>Stats generated on " + t.strftime("%m.%d.%Y at %I:%M %p") + "</p>"

# team stats
f = File.open(team_file)
doc = Nokogiri::HTML(f)
f.close

# remove unneeded columns
i = 0
doc.css('th').each do |column|
  if (i == 5 or i == 6)
    column.remove
  end
  i = i + 1
end

doc.css('tr').each do |row|
  i = 0
  row.children.each do |column|
    if (i == 5 or i == 6)
      column.remove
    end
    i = i + 1
  end
end

# get stats table
doc.xpath('//div/center/table').each do |text|
  output = text.to_s
  output.gsub!(/border="1"/, "style='background: #666; width: 88%;'")
  output.gsub!(/align="left"/, "style='background: #fff; text-align: left; padding: 5px 5px 5px 10px;'")
  output.gsub!(/<th>/, "<th style='background: #ccc; text-align: left; padding: 5px 5px 5px 10px;'>")
  output.gsub!(/<td>/, "<td style='background: #fff; text-align:left; padding: 5px 5px 5px 10px;'>")
  puts "<h1 id='team' style='margin-bottom: 0px;'>Team Statistics</h1>"
  puts output
end

puts '<br/>'

# individual stats
f = File.open(ind_file)
doc = Nokogiri::HTML(f)
f.close

# remove unneeded columns
i = 0
doc.css('th').each do |column|
  if (i == 8 or i == 9)
    column.remove
  end
  i = i + 1
end

doc.css('tr').each do |row|
  i = 0
  row.children.each do |column|
    if (i == 8 or i == 9)
      column.remove
    end
    i = i + 1
  end
end

# get stats table
doc.xpath('//div/center/table').each do |text|
  output = text.to_s
  output.gsub!(/border="1"/, "style='background: #666; width: 88%;'")
  output.gsub!(/align="left"/, "style='background: #fff; text-align: left; padding: 5px 5px 5px 10px;'")
  output.gsub!(/<th>/, "<th style='background: #ccc; text-align:left; padding: 5px 5px 5px 10px;'>")
  output.gsub!(/<td>/, "<td style='background: #fff; text-align:left; padding: 5px 5px 5px 10px;'>")
  puts "<h1 id='individual' style='margin-bottom: 0px;'>Individual Statistics</h1>"
  puts output
end

puts '<br/>'

# read from our output buffer and write it to a file
buffer.rewind
html = buffer.read

# fix spelling errors
html.gsub!('Loses','Losses')
html.gsub!('Avg Score','Average Score')

if (division == 'dx1' or division == 'dx2' or division == 'lx1' or division == 'lx2')
  html.gsub!('Individual Statistics','Individual Statistics (Pools Combined)')
end

File.open(stats_file, 'w') {|f| f.write(html) }

# update the database
begin
  mysql_html = dbh.escape_string(html)
  query = "update statistics set body = '#{mysql_html}' where name = '" + division + "'"
  dbh.query(query)
rescue Mysql::Error => e
  $stderr.puts "Error code: #{e.errno}"
  $stderr.puts "Error message: #{e.error}"
  $stderr.puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
end

# disconnect from mysql server
dbh.close if dbh
