#!/usr/bin/env ruby
require "open3"
require "socket"
include Open3

# Site Configuration Options
#   site: absolute path to the site
#   user: OS user name
#   db_user: database user name
#   db_password: database password
#   jupiter: install jupiter boolean flag
#   visual_composer: install vc boolean flag
#   analytics: install Google analytics into child theme boolean
#   go_portfolio: install Go Portfolio
#   booked: install Booked
#   edge: install latest Wordpress from GitHub

sites = {
 lynann: {
    site: '/opt/wordpress/lynann',
    user: 'mbs',
    db_user: 'lynann',
    db_name: 'lynann_wp',
    db_password: 'santosa',
    jupiter: true
  },
 play: {
    site: '/opt/wordpress/play',
    user: 'mbs',
    db_user: 'play',
    db_name: 'play_wp',
    db_password: 'santosa',
    visual_composer: true,
    go_portfolio: true
  },
  scratch: {
    site: '/opt/wordpress/scratch',
    user: 'mbs',
    db_user: 'scratch',
    db_name: 'scratch_wp',
    db_password: 'santosa',
    jupiter: true,
    visual_composer: false
  },
  jupiter: {
    site: '/opt/wordpress/jupiter',
    user: 'mbs',
    db_user: 'jupiter',
    db_name: 'jupiter_wp',
    db_password: 'santosa',
    jupiter: true
  },
  jupiter2: {
    site: '/opt/wordpress/jupiter2',
    user: 'mbs',
    db_user: 'jupiter2',
    db_name: 'jupiter2_wp',
    db_password: 'santosa',
    jupiter: true
  },
  thirdmode: {
    site: '/opt/wordpress/thirdmode',
    user: 'mbs',
    db_user: 'thirdmode',
    db_name: 'thirdmode_wp',
    db_password: 'santosa',
    jupiter: true
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
  INSTALL_JUPITER = config[:jupiter]
  INSTALL_JS_COMPOSER = config[:visual_composer]
  INSTALL_GO_PORTFOLIO = config[:go_portfolio]
end

puts "Using site #{SITE}"
puts "Linux user acct is #{USER}"
puts "Name of database: #{DB_NAME}"
puts "Database user: #{DB_USER}"
puts "Datbase password: #{DB_PASSWORD}"
puts "Install Jupiter: #{INSTALL_JUPITER}"
puts "Use Visual Composer: #{INSTALL_JS_COMPOSER}"
puts "Install Go Portfolio: #{INSTALL_GO_PORTFOLIO}"

# Currently, one of thirdmode or Thetis-2.local.
hostname = Socket.gethostname
if hostname == "thirdmode"
  APACHE_GROUP = "www-data" # for Ubuntu
  APACHE_USER = "www-data" # for Ubuntu
elsif hostname == "Thetis-2.local"
  APACHE_GROUP = "daemon" # for MAC OS X
  APACHE_USER = "daemon" # for MAC OS X
else
  puts "Can't determine hostname"
  exit 3
end

INSTALL_USER = APACHE_USER
INSTALL_GROUP = APACHE_GROUP

ROOT_DB_PASSWORD = "har526"
WP_DIST = "/opt/packages/wordpress-4.2.2.zip"
MYSQL = "/usr/local/mysql/bin/mysql"
JUPITER_MAIN = "/opt/envato/jupiter/main"
JS_COMPOSER = "/opt/envato/visual/js_composer.zip"
GO_PORTFOLIO = "/opt/envato/go/go_portfolio.zip"

puts "Deleting site directory"
%x[rm -rf #{SITE}]
%x[mkdir -p #{SITE}]

# Unzip distribution into the site directory.
puts "Unzipping Wordpress distribution into site directory"
# %x[(cd #{SITE} && tar xzvf #{WP_DIST})]
%x[(cd #{SITE} && unzip #{WP_DIST})]
%x[mv #{SITE}/wordpress/* #{SITE}]
%x[rmdir #{SITE}/wordpress]

if INSTALL_JUPITER
  puts "Installing Jupiter"
  %x[(cd #{SITE}/wp-content/themes && unzip -o #{JUPITER_MAIN}/jupiter.zip && rm -rf __MACOSX)]
  %x[(cd #{SITE}/wp-content/themes && unzip -o #{JUPITER_MAIN}/Jupiter-child.zip && rm -rf __MACOSX)]
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{JUPITER_MAIN}/Plugins/LayerSlider-*.zip && rm -rf __MACOSX)]
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{JUPITER_MAIN}/Plugins/masterslider-installable-*.zip && rm -rf __MACOSX)]
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{JUPITER_MAIN}/Plugins/revslider-* && rm -rf __MACOSX)]
end

if INSTALL_JS_COMPOSER
  puts "Installing Visual Composer"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{JS_COMPOSER})]
end

if INSTALL_GO_PORTFOLIO
  puts "Installing Go Portfolio"
  %x[(cd #{SITE}/wp-content/plugins && unzip -o #{GO_PORTFOLIO})]
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

if INSTALL_JUPITER
  puts "Adjusting WP_MEMORY_LIMIT"
  filename = "#{SITE}/wp-includes/default-constants.php"
  text = File.read(filename)
  regexp = /define\('WP_MEMORY_LIMIT', '\d+M'\)/
  replace = "define(\'WP_MEMORY_LIMIT\', \'128M\')"
  text = text.gsub(regexp, replace)
  File.open(filename, "w") {|file| file.puts text}
end

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

puts "Creating empty .htaccess file."
%x[touch #{SITE}/.htaccess]
%x[chown #{USER}:#{APACHE_GROUP} #{SITE}/.htaccess]
%x[chmod 775 #{SITE}/.htaccess]

puts "Recreating database."
puts "running: mysql -u root -p#{ROOT_DB_PASSWORD}"
Open3.popen3("#{MYSQL} -u root -p#{ROOT_DB_PASSWORD}") do |stdin, stdout, stderr|
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

