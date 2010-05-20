# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rtt}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcelo Giorgi"]
  s.date = %q{2010-05-13}
  s.default_executable = %q{rtt}
  s.description = %q{RTT is a tool for tracking time}
  s.email = %q{marklazz.uy@gmail.com}
  s.executables = ["rtt"]
  s.extra_rdoc_files = ["LICENSE", "README.rdoc", "bin/rtt", "lib/rtt.rb", "lib/rtt/client.rb", "lib/rtt/project.rb", "lib/rtt/task.rb", "lib/rtt/user.rb"]
  s.files = ["LICENSE", "README.rdoc", "Rakefile", "bin/rtt", "db/test.sqlite3", "lib/rtt.rb", "lib/rtt/client.rb", "lib/rtt/project.rb", "lib/rtt/task.rb", "lib/rtt/user.rb", "spec/datamapper_spec_helper.rb", "spec/lib/rtt_spec.rb", "Manifest", "rtt.gemspec"]
  s.homepage = %q{http://}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Rtt", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rtt}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{RTT is a tool for tracking time}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
