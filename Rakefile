require "rake"
require "rake/rdoctask"
require "rspec"
require "rspec/core/rake_task"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "scoped-search"
    gem.summary = %Q{Easily implement search forms and column ordering based on your models scopes}
    gem.description = %Q{Easily implement search forms and column ordering based on your models scopes. For Rails 3, compatible with ActiveRecord and Mongoid.}
    gem.email = "slainer68@gmail.com"
    gem.homepage = "http://github.com/novagile/scoped-search"
    gem.authors = ["slainer68"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

Rspec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "scoped_search #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

