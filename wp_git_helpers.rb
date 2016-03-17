require 'open3'

module WpGitHelpers

  def check_and_expand_commit(commit)
    return nil unless commit
    line = %x[git show -s #{commit}| sed 1q]
    return nil unless $? == 0
    commit = line.split[1]
    return commit
  end

  def is_clean
    clean_msg =  "nothing to commit, working directory clean\n"
    stdin, stdout, stderr = Open3.popen3('git status')
          if stdout.gets == "On branch master\n" &&
                (stdout.gets == clean_msg ||
		  stdout.gets == clean_msg || stdout.gets == clean_msg)
                return true;
          end
          return false
  end

  def get_head_commit
    check_and_expand_commit("HEAD")
  end

end
