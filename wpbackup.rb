#!/usr/bin/env ruby

require_relative 'wp_git_helpers'

class WpBackup
	include WpGitHelpers
	def do_backup
		unless is_clean 
			puts "Please commit your work first\n"
		else
			commit = get_head_commit
			puts "Backing up revision #{commit}"
		    %x[mysqldump -u root -phar526 niroga_wp > ../backups/niroga-#{commit}.sql]
		    if $? == 0
		    	puts "Backup succeeded"
		    else
		    	puts "Backup failed"
		    end
		end
	end
end

x = WpBackup.new
x.do_backup