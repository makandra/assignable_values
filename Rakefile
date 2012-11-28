require 'rake'
require 'bundler/gem_tasks'

desc 'Default: Run all specs.'
task :default => 'all:spec'

namespace :all do

  desc "Run specs on all spec apps"
  task :spec do
    for_each_directory_of('spec/**/Rakefile') do |directory|
      env = "SPEC=../../#{ENV['SPEC']} " if ENV['SPEC']
      system("cd #{directory} && #{env} bundle exec rake spec")
    end
  end

  namespace :bundle do

    desc "Bundle all spec apps"
    task :install do
      for_each_directory_of('spec/**/Gemfile') do |directory|
        system("cd #{directory} && bundle install")
      end
    end

    desc "Update all gems, or a list of gem given by the GEM environment variable"
    task :update do
      for_each_directory_of('spec/**/Gemfile') do |directory|
        system("cd #{directory} && bundle update #{ENV['GEM']}")
      end
    end

  end

end

def for_each_directory_of(path, &block)
  Dir[path].sort.each do |rakefile|
    directory = File.dirname(rakefile)
    puts '', "\033[44m#{directory}\033[0m", ''
    block.call(directory)
  end
end
