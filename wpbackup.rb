#!/usr/bin/env ruby

require_relative 'wp_git_helpers'

exit 0

unless is_clean 
	puts "Please commit your work first\n"
else
	commit = get_head_commit
	puts "Backing up revision #{commit}"
        %x[mysqldump -u root -phar526 niroga_wp > ../backups/niroga-#{commit}.sql]
end