#!/usr/bin/env ruby

require_relative 'wp_git_helpers'
PROG = "s3util"
ORG = "thirdmode"

class S3Backup
	BASE = "/opt/wordpress/backups"
        RESTORE_BASE = "/opt/wordpress/restores"
	REGION = "us-west-1"

	include WpGitHelpers

	def wp_site
            return (@site || (@site = Dir.pwd.split('/')[-1]))
	end

	def backup
		unless is_clean 
			puts "Please commit your work first\n"
		else
		    commit = get_head_commit
                    backup_file = "#{BASE}/#{wp_site}-#{commit}.sql"
		    bucket_url = "s3://thirdmode.#{wp_site}"
                    puts "Copying #{backup_file} to #{bucket_url}"
                    %x[aws s3 cp #{backup_file} #{bucket_url}  --region #{REGION}]
		    if $? == 0
		    	puts "Backup succeeded"
		    else
		    	puts "Backup failed"
		    end
		end
	end

	# Show all the backups in this bucket.
	def list
	    bucket_url = "s3://thirdmode.#{wp_site}"
	    output = %x[aws s3 ls #{bucket_url} --region #{REGION} 2>&1]
            puts "Files in the thirdmode.#{wp_site} bucket are:\n"
            puts output
	end

	def restore(name)
	    bucket_url = "s3://thirdmode.#{wp_site}"
            if name
		backup_file = name
	    else
                commit = get_head_commit
                backup_file = "#{wp_site}-#{commit}.sql"
            end
            file_url = "#{bucket_url}/#{backup_file}"
            puts "Restoring #{backup_file} from bucket #{bucket_url} to #{RESTORE_BASE}\n"
            output = %x[aws s3 cp #{file_url} #{RESTORE_BASE}  --region #{REGION} 2>&1]
            puts output
	    if $? == 0
	    	puts "Restore succeeded"
	    else
	    	puts "Restore failed"
	    end
	end
end

x = S3Backup.new
if ARGV[0] == "-b"
    x.backup
elsif ARGV[0] == "-l"
    x.list
elsif ARGV[0] == "-r"
    x.restore(ARGV[1])
else
    puts "You must be in a wordpress site top-level directory.  Directories ../backups\n"
    puts "  and ../restores must exist.  The bucket #{ORG}.#{x.wp_site} must exist on Amazon S3.\n"
    puts "Usage: #{PROG} -b to copy database backup to Amazon S3 bucket for this site,\n"
    puts "  or #{PROG} -l to list files in the bucket. Restore last backup with #{PROG} -r\n"    
    puts "  or restore specific backup file with #{PROG} -r <backup_file_name>.\n" 
end
