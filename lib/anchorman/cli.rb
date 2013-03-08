module Anchorman
  class CLI < Thor

    include Thor::Actions

    desc "generate", "Generates a draft release notes document"
    def generate
      repo = open_repo
      commits = repo.log

      return unless commits.size

      say "#{commits.size} commit(s) found - building notes", :green

      empty_directory 'anchorman'

      header = "# Release Notes\n\n ## Summary\n\n ## Changes\n\n"
      formatter = CommitFormatter.new(repo)
      notes =  commits.collect {|c| formatter.format(c) }.join("\n\n")

      create_file 'anchorman/release_notes.md' do
        header + notes
      end

    end

    no_tasks do

      def open_repo
        repo = Git.open('.')
        repo.log.size # this will raise if no repo or no commits
        repo
      rescue ArgumentError
        say 'No git repo found', :red
      rescue Git::GitExecuteError
        say 'No git log found', :red
      end

    end
  end
end