#!/usr/bin/env ruby
#
# Restore to a given commit COMMIT.  Safety checks:  
#
# (1) Make sure that the commit exists.
# (2) Make sure that a database backup
#     with the name #{SITE}-#{COMMIT}.sql exists in the backup directory.
# (3) Make sure that the working directory is clean

require 'open3'

def check_and_expand_commit(commit)
  return false unless commit
  puts "Checking commit: #{commit}"
  line = %x[git show -s #{commit}| sed 1q]
  return false unless $? == 0
  commit = line.split[1]
  return commit
end

def is_clean
  stdin, stdout, stderr = Open3.popen3('git status')
        if stdout.gets == "On branch master\n" &&
	      stdout.gets == "nothing to commit, working directory clean\n"
	      return true;
	end
	return false
end

def get_head_commit
        line = %x[git show -s HEAD]
        commit = line[1]
        if commit.length != 40
                puts "Can't get HEAD commit"
                return nil
        end
        return commit
end

def first_commit

unless ARGV[0]
  puts "Usage: wprestore <commit>"
  exit 2
end

commit = check_and_expand_commit(ARGV[0])

if commit == false
  puts "invalid commit: ARGV[0]"
  exit 1
end
puts "expanded commit is #{commit}"

site = Dir.pwd.split('/')[-1]
BASE = "/opt/wordpress/backups"

backup_file = "#{BASE}/#{site}-#{commit}.sql"

unless File.exist?(backup_file)
  puts "No database for this commit: #{commit}"
  exit 3
end

puts "backup file is #{backup_file}"

puts "%x[mysqladmin -u root -phar526 -f drop #{site}_wp]"

puts "%x[mysqladmin -u root -phar526 create  #{site}_wp]"

puts "%x[mysql -u root -phar526 niroga_wp < #{backup_file}]"

### 
### reset destroys everything after given commit
### puts "%x[sudo -u daemon git reset --hard ${commit}]"
###
### We want a git checkout instead???? What about "detached head"?
puts "%x[git checkout #{commit}]"

# remove untracked files and directories
puts "%x[sudo -u daemon git clean -d -f]"



