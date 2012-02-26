require 'rubygems'
require 'echoe'

# PACKAGING ============================================================

Echoe.new('rtt', '0.0.0.47') do |p|
  p.description = 'RTT is a tool for tracking time'
  p.url = 'http://github.com/marklazz/rtt'
  p.author = 'Marcelo Giorgi'
  p.email = 'marklazz.uy@gmail.com'
  p.ignore_pattern = [ 'tmp/*', 'script/*', '*.sh' ]
  p.runtime_dependencies = [
      ['highline', "1.5.2"], ['activesupport', '>= 2.3.5', '<= 2.3.8'], ['prawn', '0.8.4'], ['dm-core', '1.0.0'], [ 'dm-validations', '1.0.0'], [ 'dm-migrations', '1.0.0'], ['dm-sqlite-adapter', '1.0.0'], [ 'rake', '0.8.2' ], [ 'addressable', '2.2.7' ],
      [ 'allison', '2.0.3'], [ 'data_objects', '0.10.2' ], [ 'extlib', '0.9.15' ], [ 'json_pure', '1.6.5' ], [ 'prawn-core', '0.8.4' ], [ 'prawn-layout', '0.8.4'], ['prawn-security', '0.8.4'],  ['haml', '2.2.24'], ['hanna', '0.1.12'], ['metaclass', '0.0.1'],
      ['rspec', '1.3.0' ], ['mocha', '0.10.4'], ['rubyforge', '2.0.4'], ['rdoc', '2.3.0'], [ 'gemcutter', '0.7.1'], ['echoe', '4.5.6']
   ]
  p.development_dependencies = [ ]
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
