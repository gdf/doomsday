#!/usr/bin/env ruby
require 'grit'


def commit_versions(msg)
  Dir.chdir($repo) do
    run("git", "add", "versions.json")
    run("git", "commit", "-m", "'#{msg}'", "--author='#{sso_author}'")
    run("git", "push", "origin", "master")
  end
end

def tag_release(tag, o={:force=>false})
  Dir.chdir($repo) do
    if o[:force]
      run("git", "tag", "-f", tag)
    else
      run("git", "tag", tag)
    end
    run("git", "push", "origin", tag)
  end
end

def rollback_to(tag)
  tag_release("before_rollback_to-#{tag}", {:force => true})
  Dir.chdir($repo) do
    run("git", "revert", "-n", "#{tag}..HEAD")
    run("git", "commit", "-m", "'REVERTED to #{tag}'")
    run("git", "push", "origin", "master")
  end
end

get '/history' do
  headers "Content-Type" => "application/json"

  r = Grit::Repo.new($repo)

  tags = []
  tag_ids = {}
  r.tags.each do |t|
    if t.name =~ /-before-/
      tags << {"id" => t.commit, "message" => t.message, "name" => t.name, "date" => t.tag_date, "author" => t.tagger.name, "email" => t.tagger.email}
      tag_ids[t.commit.to_s] = t.name
    end
  end

  data = []
  r.commits("master", 32).each do |c|
    c.diffs.each do |diff|
      if diff.a_path == "versions.json"
        # ... "diff" => diff.diff
        d = {"id" => c.id, "message" => c.message, "date" => c.committed_date, "author" => c.author.name, "email" => c.author.email, "has_tag" => false, "tag" => ""}
        if tag_ids.has_key?(c.id)
          d["has_tag"] = true
          d["tag"] = tag_ids[c.id]
        end
        data << d
        break
      end
    end
  end 
  return {
    "history" => data,
    "tags" => tags,
  }.to_json
end

