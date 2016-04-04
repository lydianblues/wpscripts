#!/usr/bin/env ruby

require_relative 'wp_git_helpers'

class WpBackup
	BASE = "/opt/wordpress/backups"
        MASTER_PASSWORD = "har526"

	include WpGitHelpers
	def do_backup
		unless is_clean 
			puts "Please commit your work first\n"
		else
		    site = Dir.pwd.split('/')[-1]
		    commit = get_head_commit
                    backup_file = "#{BASE}/#{site}-#{commit}.sql"
                    db_name = "#{site}_wp"
                    puts "Backing up #{db_name} to file: #{backup_file}"
		    %x[mysqldump -u root -p#{MASTER_PASSWORD} #{db_name} > #{backup_file}]
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
