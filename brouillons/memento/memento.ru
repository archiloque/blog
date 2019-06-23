unless ENV.key? 'PATH_TO_GIT_REPO'
  raise 'Need a PATH_TO_GIT_REPO env parameter'
end

PATH_TO_GIT_REPO = ENV['PATH_TO_GIT_REPO']
STDOUT << "Specified git repo dir is [#{PATH_TO_GIT_REPO}]\n"
STDOUT << "Full git repo dir is [#{File.expand_path(PATH_TO_GIT_REPO)}]\n"

unless File.directory?(PATH_TO_GIT_REPO)
  raise "Path [#{PATH_TO_GIT_REPO}] is not a directory"
end

check_git_repo = `git rev-parse --is-inside-work-tree --git-dir=\"#{PATH_TO_GIT_REPO}\"`
unless check_git_repo.split("\n")[0] == 'true'
    raise "Path [#{PATH_TO_GIT_REPO}] does not seem to be a git repo"
    STDERR << check_git_repo
end
STDOUT << "Dir is a git directory \\o/\n"

Dir.chdir PATH_TO_GIT_REPO

# Identify lines that looks like a git line deletion
LINE_FILTERING_REGEX = /\A\-([^-])(.*)\z/

require 'time'

class Memento

  def find_content
    number_of_commits = `git rev-list --count MASTER`.split("\n")[0].to_i
    commit_rank = rand(number_of_commits + 1)
    all_lines = `git log -p --skip=#{commit_rank} --max-count=1`.split("\n")
    interesting_lines = all_lines.select do |line|
      line.match(LINE_FILTERING_REGEX)
    end
    if interesting_lines.length == 0
      return nil
    end
    line_index = rand(interesting_lines.length)
    # Remove the '-' at the beginning of the line
    content = interesting_lines[line_index][1..-1]
    # Fetch the commit date
    date_string = `git log --pretty=format:"%aI" --skip=#{commit_rank} --max-count=1`.split("\n")[0]
    date = Time.iso8601(date_string)
    {content: content, date: date}
  end

  def call(env)
    # Loop until we find a result
    until((result = find_content))
    end
formatted_result = <<-HTML
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Deleted code memorial</title>
    <style>
      body {
        background: black;
        color: white;
        text-align: center;
        font-family: Copperplate, "Copperplate Gothic Light", fantasy;
      }
      #gitContent {
        padding-top: 10%;
        padding-left: 20%;
        padding-right: 20%;
        padding-bottom: 5%;
        font-size: 36px;
      }
      #gitDate {
        font-size: 16px;
      }
    </style>
  </head>
  <body>
    <div id="gitContent">&#x1f56f;<br>#{result[:content]}<br>&#x1f56f;</div>
    <div id="gitDate">Deteted on #{result[:date].strftime('%A %B %e %Y %H:%M:%S')}</div>
  </body>
</html>
HTML
    [200, {"Content-Type" => "text/html"}, [formatted_result]]
  end
end

run Memento.new