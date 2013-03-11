module Anchorman
  NOTES_HEADER = "# Release Notes\n\n## Summary\n\n## Changes\n\n"
  NOTES_FOOTER = "\n\n\------\n\n_Release Notes generated with [Anchorman](http://github.com/infews/anchorman)_"

  class CLI < Thor

    include Thor::Actions

    desc "notes", "Generates a draft release notes document"
    method_options from: :string, to: :string, name: "release_notes"
    def notes
      git = open_repo

      commits = if options[:from]
                  git.log.between options[:from], options[:to]
                else
                  git.log
                end

      return unless commits.size

      say "#{commits.size} commit(s) found - building notes", :green

      empty_directory 'release_notes'

      formatter = CommitFormatter.new(Repo.new(git))
      notes =  commits.collect {|c| formatter.format(c) }.join("\n\n")

      create_file "release_notes/#{options[:name]}.md" do
        NOTES_HEADER + notes + NOTES_FOOTER
      end

    end

    no_tasks do

      def open_repo
        git = Git.open('.')
        git.log.size # this will raise if no repo or no commits
        git
      rescue ArgumentError
        say 'No git repo found', :red
      rescue Git::GitExecuteError
        say 'No git log found', :red
      end

    end
  end
end