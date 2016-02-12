#!/usr/bin/env ruby
#
# Restore to a given commit COMMIT.  Safety checks:  
#
# (1) Make sure that the commit exists.
# (2) Make sure that a database backup
#     with the name #{SITE}-#{COMMIT}.sql exists in the backup directory.
# (3) Make sure that the working directory is clean

require_relative 'wp_git_helpers'

class WpRestore

  BASE = "/opt/wordpress/backups"

  include WpGitHelpers

  def do_restore(acommit)

    if acommit
      commit = check_and_expand_commit(acommit)
    else
      commit = get_head_commit
    end

    unless commit && commit.length == 40
      puts "Could not find commit to restore"
      exit 1
    end

    puts "expanded commit is #{commit}"

    site = Dir.pwd.split('/')[-1]
    
    backup_file = "#{BASE}/#{site}-#{commit}.sql"

    unless File.exist?(backup_file)
      puts "No database for this commit: #{commit}"
      exit 2
    end

    puts "Restoring from backup file: #{backup_file}"

    %x[mysqladmin -u root -phar526 -f drop #{site}_wp]

    %x[mysqladmin -u root -phar526 create  #{site}_wp]

    %x[mysql -u root -phar526 #{site}_wp < #{backup_file}]

    puts <<GIT_INSTRUCTIONS
    ### 
    ### Reset destroys everything after given commit:
    ###   sudo -u daemon git reset --hard <sha1-of-commit>
    ###
    ### Checkout with a detached HEAD:
    ###   git checkout <sha1-of-commit>
    ###
    ### Create new branch of earlier commit:
    ###   git branch branchname <sha1-of-commit>
    ###
    ### Remove untracked files and directories:
    ###   puts "%x[sudo -u daemon git clean -d -f]"
    ###
GIT_INSTRUCTIONS
  end
end

x = WpRestore.new

x.do_restore(ARGV[0])
