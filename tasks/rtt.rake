require 'rake/clean'
require 'fileutils'
require 'date'
require 'spec/rake/spectask'
require 'hanna/rdoctask'

# Removes spec task defiened in dependency gems
module Rake
  def self.remove_task(task_name)
    Rake.application.instance_variable_get('@tasks').delete(task_name.to_s)
  end
end
Rake.remove_task 'spec'

def source_version
  line = File.read('lib/rtt.rb')[/^\s*VERSION = .*/]
  line.match(/.*VERSION = '(.*)'/)[1]
end

# SPECS ===============================================================

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--color']
  t.rcov = false
  t.spec_files = FileList['spec/lib/*_spec.rb']
end

task :default => :spec

# Rcov ================================================================
namespace :spec do
  desc 'Mesures test coverage'
  task :coverage do
    rm_f "coverage"
    rcov = "rcov --text-summary -Ilib"
    system("#{rcov} --no-html --no-color spec/lib/*_spec.rb")
  end
end

# Website =============================================================
# Building docs requires HAML and the hanna gem:
#   gem install mislav-hanna --source=http://gems.github.com

desc 'Generate RDoc under doc/api'
task 'doc'     => ['doc:api']

task 'doc:api' => ['doc/api/index.html']

file 'doc/api/index.html' => FileList['lib/**/*.rb','README.rdoc'] do |f|
  require 'rbconfig'
  hanna = RbConfig::CONFIG['ruby_install_name'].sub('ruby', 'hanna')
  rb_files = f.prerequisites
  sh((<<-end).gsub(/\s+/, ' '))
    #{hanna}
      --charset utf8
      --fmt html
      --inline-source
      --line-numbers
      --main README.rdoc
      --op doc/api
      --title 'RTT API Documentation'
      #{rb_files.join(' ')}
  end
end
CLEAN.include 'doc/api'
