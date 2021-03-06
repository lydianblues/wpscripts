#!/usr/bin/env ruby
require "open3"
require "socket"
require "io/console"
include Open3

# Site Configuration Options
#   site: absolute path to the site
#   user: OS user name
#   db_user: database user name
#   db_password: database password
#   jupiter: install jupiter boolean flag
#   avada: install avada boolean flag
#   tempera: install tempera boolean flag
#   visual_composer: install vc boolean flag
#   analytics: install Google analytics into child theme boolean
#   go_portfolio: install Go Portfolio
#   booked: install Booked
#   rev_slider: install Slider Revolution
#   layer_slider: Layer Slider
#   master_slider: install Master Slider
#   events_calendar: install theeventscalendar base, pro, and filterbar
#   edge: install latest Wordpress from GitHub
#   woo_commerce: install Woo Commerce 
#   clean_login: install Clean Login

sites = {
  proto: {
    site: '/opt/wordpress/proto',
    user: 'mbs',
    db_user: 'bare',
    db_name: 'bare_wp',
    db_password: 'santosa',
    jupiter: true,
    clean_login: true
  },
  envato: {
	site: '/opt/wordpress/envato',
	user: 'mbs',
	db_user: 'envato',
	db_name: 'envato_wp',
	db_password: 'santosa',
	jupiter: true,
	avada: true,
	tempera: true,
	visual_composer: true,
	go_portfolio: true,
	booked: true,
	rev_slider: true,
	layer_slider: true,
	master_slider: true,
  },
  bare: {
    site: '/opt/wordpress/bare',
    user: 'mbs',
    db_user: 'bare',
    db_name: 'bare_wp',
    db_password: 'santosa'
  },
 lynann: {
    site: '/opt/wordpress/lynann',
    user: 'mbs',
    db_user: 'lynann',
    db_name: 'lynann_wp',
    db_password: 'santosa',
    avada: true,
    layer_slider: true,
    rev_slider: true,
    events_calendar: true,
    edge: false
  },
 play: {
    site: '/opt/wordpress/play',
    user: 'mbs',
    db_user: 'play',
    db_name: 'play_wp',
    db_password: 'santosa',
    rev_slider: false,
    master_slider: false,
    go_portfolio: false,
    visual_composer: false,
    booked: false,
    tempera: false,
    jupiter: true,
    edge: false
  },
 dmind: {
    site: '/opt/wordpress/dmind',
    user: 'mbs',
    db_user: 'dmind',
    db_name: 'dmind_wp',
    db_password: 'santosa',
    jupiter: true
 },
master: {
    site: '/opt/wordpress/master',
    user: 'mbs',
    db_user: 'master',
    db_name: 'master_wp',
    db_password: 'santosa',
    booked: true
    # master_slider: true
  },
  scratch: {
    site: '/opt/wordpress/scratch',
    user: 'mbs',
    db_user: 'scratch',
    db_name: 'scratch_wp',
    db_password: 'santosa',
    jupiter: false,
    visual_composer: true,
    master_slider: true,
    go_portfolio: true
  },
  jenny: {
    site: '/opt/wordpress/jenny',
    user: 'mbs',
    db_user: 'jenny',
    db_name: 'jenny_wp',
    db_password: 'santosa',
    jupiter: true
  },
  jupiter2: {
    site: '/opt/wordpress/jupiter2',
    user: 'mbs',
    db_user: 'jupiter2',
    db_name: 'jupiter2_wp',
    db_password: 'santosa',
    jupiter: true,
    events_calendar: true,
  },
  niroga: {
    site: '/opt/wordpress/niroga',
    user: 'mbs',
    db_user: 'niroga',
    db_name: 'niroga_wp',
    db_password: 'santosa',
    jupiter: true
  },
  thirdmode: {
    site: '/opt/wordpress/thirdmode',
    user: 'mbs',
    db_user: 'thirdmode',
    db_name: 'thirdmode_wp',
    db_password: 'santosa',
    avada: true
  },
  jrootes: {
    site: '/home/jrootes/wordpress',
    user: 'jrootes',
    db_user: 'jrootes',
    db_name: 'jrootes_wp',
    db_password: 'ahimsa',
    jupiter: false
  }
}

def display_sites(sites)
  arr = sites.keys.map do |key|
   key.to_s
  end
  arr.join(', ') 

end
site = ARGV[0]
unless site
  puts "Please specify a site: #{display_sites(sites)}"
  exit 1
end
unless sites.has_key?(site.to_sym) 
  puts "Unknown site #{site}."
  exit 2
else
  config = sites[site.to_sym]
  SITE = config[:site] 
  USER = config[:user]
  DB_NAME = config[:db_name]
  DB_USER = config[:db_user]
  DB_PASSWORD = config[:db_password]
  INSTALL_WORDPRESS_EDGE = config[:edge]

  # Installable features:
  INSTALL_JUPITER = config[:jupiter]
  INSTALL_AVADA = config[:avada]
  INSTALL_TEMPERA = config[:tempera]
  INSTALL_JS_COMPOSER = config[:visual_composer]
  INSTALL_GO_PORTFOLIO = config[:go_portfolio]
  INSTALL_REV_SLIDER = config[:rev_slider]
  INSTALL_MASTER_SLIDER = config[:master_slider]
  INSTALL_LAYER_SLIDER = config[:layer_slider]
  INSTALL_EVENTS_CALENDAR = config[:events_calendar]
  INSTALL_BOOKED = config[:booked]
  INSTALL_WOO_COMMERCE = config[:woo_commerce]
  INSTALL_CLEAN_LOGIN = config[:clean_login]
end

# Not yet implemented.
INSTALL_ANALYTICS = false

hostname = Socket.gethostname
if hostname == "thirdmode"
  APACHE_GROUP = "www-data" # for Ubuntu
  APACHE_USER = "www-data" # for Ubuntu
  MYSQL_SOCK = "/var/run/mysqld/mysqld.sock"
  INSTALL_GROUP = "mbs"
elsif ["Thetis-2.local", "Thetis.local"].include?(hostname)
  APACHE_GROUP = "daemon" # for MAC OS X
  APACHE_USER = "daemon" # for MAC OS X
  MYSQL_SOCK = "/tmp/mysql.sock"
  INSTALL_GROUP = "staff"
elsif hostname == "threnody"
  APACHE_GROUP = "www-data" # for Ubuntu
  APACHE_USER = "www-data" # for Ubuntu
  MYSQL_SOCK = "/tmp/mysql.sock"
  INSTALL_GROUP = "mbs"
else
  puts "Unknown Hostname"
  exit 1
end

# The installed tree has Apache uid.

INSTALL_USER = APACHE_USER

ROOT_DB_PASSWORD = "har526"
WP_DIST = "/opt/packages/wordpress-4.5.2.zip"
TEMPERA = "/opt/packages/tempera.1.4.0.1.zip"
MYSQL = "/usr/local/mysql/bin/mysql"

JUPITER_MAIN="/opt/envato/jupiter5/jupiter-main-package"

AVADA_HOME = "/opt/envato/avada/Avada_Full_Package/Avada Theme"
AVADA_MAIN = "#{AVADA_HOME}/Avada.zip"
AVADA_CHILD = "#{AVADA_HOME}/Avada-Child-Theme.zip"

JS_COMPOSER = "/opt/envato/visual/js_composer.zip"
REV_SLIDER = "/opt/envato/revslider/revslider.zip"
MASTER_SLIDER = "/opt/envato/masterslider/masterslider-installable.zip"
LAYER_SLIDER = "/opt/envato/layerslider/layersliderwp-5.6.8.installable.zip"
EVENTS_CALENDAR_HOME="/opt/packages/theeventscalendar"
EVENTS_CALENDAR_BASE= "#{EVENTS_CALENDAR_HOME}/the-events-calendar.4.1.2.zip"
EVENTS_CALENDAR_PRO = "#{EVENTS_CALENDAR_HOME}/events-calendar-pro.4.1.2.zip"
EVENTS_CALENDAR_FILTER = "#{EVENTS_CALENDAR_HOME}/the-events-calendar-filterbar.4.1.0.zip"
BOOKED = "/opt/envato/booked/Booked_v1.7.14/booked.zip"
GO_PORTFOLIO = "/opt/envato/go/go_portfolio.zip"
WOO_COMMERCE = "/opt/packages/woocommerce.2.5.5.zip"
CLEAN_LOGIN = "/opt/packages/clean-login.zip"

puts "Using site: #{SITE}"
puts "Linux user acct: #{USER}"
puts "Name of database: #{DB_NAME}"
puts "Database user: #{DB_USER}"
puts "Datbase password: #{DB_PASSWORD}"
puts "Hostname : #{hostname}"
puts "Install user: #{INSTALL_USER}"
puts "Install group: #{INSTALL_GROUP}"
puts "MySQL socket: #{MYSQL_SOCK}"

["INSTALL_JUPITER",
  "INSTALL_AVADA",
  "INSTALL_TEMPERA",
  "INSTALL_GO_PORTFOLIO",
  "INSTALL_JS_COMPOSER",
  "INSTALL_MASTER_SLIDER", 
  "INSTALL_REV_SLIDER",
  "INSTALL_EVENTS_CALENDAR",
  "INSTALL_LAYER_SLIDER",
  "INSTALL_BOOKED",
  "INSTALL_WOO_COMMERCE",
  "INSTALL_ANALYTICS",
  "INSTALL_CLEAN_LOGIN",
  "INSTALL_WORDPRESS_EDGE"].each do |feature|
    to_install = "No"
    if eval(feature)
      to_install = "Yes"
    end
    puts feature + ": " + to_install
  end

print "Do you want to continue? (y/n): "
response = STDIN.getch

if response != "Y" && response != "y"
  puts "\nExiting..."
  exit 0
else 
  puts "\nContinuing..."
end

if Process.uid != 0
  puts "You must be root to run this program."
  exit 1
end

puts "Deleting site directory"
%x[rm -rf #{SITE}]
%x[mkdir -p #{SITE}]

if INSTALL_WORDPRESS_EDGE
  puts "Cloning Wordpress from GitHub"
  %x[cd #{SITE}/.. && git clone https://github.com/WordPress/WordPress.git #{SITE}]
else
  puts "Unzipping Wordpress distribution into site directory"
  %x[(cd #{SITE} && unzip #{WP_DIST})]
  %x[mv #{SITE}/wordpress/* #{SITE}]
  %x[rmdir #{SITE}/wordpress]
end

if INSTALL_JUPITER
  puts "Installing Jupiter Theme from complete package."
  %x[(cd #{SITE}/wp-content/themes && unzip -o #{JUPITER_MAIN}/jupiter.zip && rm -rf __MACOSX)]
  puts "Installing Jupiter Child Theme from complete package."
  %x[(cd #{SITE}/wp-content/themes && unzip -o #{JUPITER_MAIN}/jupiter-child.zip && rm -rf __MACOSX)]
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{JUPITER_MAIN}/Plugins/LayerSlider-*.zip && rm -rf __MACOSX)]
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{JUPITER_MAIN}/Plugins/masterslider-installable-*.zip && rm -rf __MACOSX)]
 %x[(cd #{SITE}/wp-content/plugins && unzip -o #{JUPITER_MAIN}/Plugins/revslider-* && rm -rf __MACOSX)]
end

if INSTALL_AVADA
  puts "Installing Avada Theme from complete package."
  %x[(cd #{SITE}/wp-content/themes && unzip -o "#{AVADA_MAIN}" && rm -rf __MACOSX)]
  puts "Installing Avada Child Theme from complete package."
  %x[(cd #{SITE}/wp-content/themes && unzip -o "#{AVADA_CHILD}" && rm -rf __MACOSX)]
 end

if INSTALL_TEMPERA
  puts "Installing Tempera Theme"
  %x[(cd #{SITE}/wp-content/themes && unzip -o #{TEMPERA})]
end

if INSTALL_JS_COMPOSER
  puts "Installing Visual Composer"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{JS_COMPOSER})]
end

if INSTALL_GO_PORTFOLIO
  puts "Installing Go Portfolio"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{GO_PORTFOLIO})]
end

if INSTALL_REV_SLIDER
  puts "Installing Slider Revolution"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{REV_SLIDER})]
end

if INSTALL_MASTER_SLIDER
  puts "Installing Master Slider"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{MASTER_SLIDER})]
end

if INSTALL_LAYER_SLIDER
  puts "Installing Layer Slider"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{LAYER_SLIDER})]
end

if INSTALL_EVENTS_CALENDAR
  puts "Installing Events Calendar"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{EVENTS_CALENDAR_BASE})]
  puts "Installing Events Calendar Pro"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{EVENTS_CALENDAR_PRO})]
  puts "Installing Events Calendar Filter Bar"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{EVENTS_CALENDAR_FILTER})]
end

if INSTALL_BOOKED
  puts "Installing Booked"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{BOOKED})]
end

if INSTALL_CLEAN_LOGIN
  puts "Installing Clean Login"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{CLEAN_LOGIN})]
end

if INSTALL_WOO_COMMERCE
  puts "Installing Woo Commerce"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{WOO_COMMERCE})]
end

# Create per-user wp-config.php.
puts "Creating wp-config.php."
input_filename = "#{SITE}/wp-config-sample.php"
output_filename = "#{SITE}/wp-config.php"
text = File.read(input_filename)
replace = text.gsub(/database_name_here/, DB_NAME)
replace = replace.gsub(/username_here/, DB_USER)
replace = replace.gsub(/password_here/, DB_PASSWORD)
File.open(output_filename, "w") {|file| file.puts replace}

# Only needed for Jupiter.
puts "Adjusting WP_MEMORY_LIMIT"
filename = "#{SITE}/wp-includes/default-constants.php"
text = File.read(filename)
regexp = /define\('WP_MEMORY_LIMIT', '\d+M'\)/
replace = "define(\'WP_MEMORY_LIMIT\', \'256M\')"
text = text.gsub(regexp, replace)
File.open(filename, "w") {|file| file.puts text}

# Fix all the permissions.
puts "Making #{INSTALL_USER}:#{INSTALL_GROUP} the user/group."
%x[chown -R #{INSTALL_USER}:#{INSTALL_GROUP} #{SITE}]

puts "Changing all file permissions to 0664."
%x[find #{SITE} -type f -exec chmod 664 {} '\;']

puts "Changing all directory permissions to 0775."
%x[find #{SITE} -type d -exec chmod 775 {} '\;']

puts "Changing permission on #{SITE}/wp-content to 0775 for all subdirs."
%x[find #{SITE}/wp-content -type d -exec chmod 775 {} '\;']

puts "Changing permission on #{SITE}/wp-content to 0664 for all files."
%x[find #{SITE}/wp-content -type f -exec chmod 664 {} '\;']

puts "Creating .htaccess file."
%x[touch #{SITE}/.htaccess]
%x[chown #{INSTALL_USER}:#{INSTALL_GROUP} #{SITE}/.htaccess]
%x[chmod 775 #{SITE}/.htaccess]
File.open("#{SITE}/.htaccess", 'w') {
	|f| f.write("php_value max_execution_time 300")
}

puts "Recreating database."
puts "running: #{MYSQL} -u root -S #{MYSQL_SOCK} -p#{ROOT_DB_PASSWORD}"
Open3.popen3("#{MYSQL} -u root -S #{MYSQL_SOCK} -p#{ROOT_DB_PASSWORD}") do 
  |stdin, stdout, stderr|

    stdin.puts("DROP DATABASE IF EXISTS #{DB_NAME};")
    stdin.puts("CREATE DATABASE #{DB_NAME};")
    stdin.puts("GRANT ALL ON #{DB_NAME}.* TO " +
        "\'#{DB_USER}\'@\'localhost\' IDENTIFIED BY \'#{DB_PASSWORD}\';")
    stdin.close
    puts stdout.gets
    puts stdout.gets
    puts stderr.gets
    puts stderr.gets
   
end

