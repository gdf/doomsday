#!/usr/bin/env ruby

$git_info = {:branch => "unknown", :rev => "unknown", :rev_short => "?"}
if File.exist?($web_dir + "/.git")
  Dir.chdir($web_dir) do
    $git_info[:branch] = `git name-rev --name-only HEAD`.chomp
    $git_info[:rev] = `git rev-parse HEAD`.chomp
    $git_info[:rev_short] = $git_info[:rev][0,7]
    # check for local, uncommitted modifications
    $git_info[:clean_repo] = system("git diff --no-ext-diff --quiet --exit-code")
    $git_info[:clean_repo] ||= system("git diff-index --cached --quiet HEAD --")
  end
end

