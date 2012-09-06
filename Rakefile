require 'rubygems'
require 'echoe'

# PACKAGING ============================================================

Echoe.new('rtt', '0.0.6') do |p|
  p.description = 'RTT is a tool for tracking time'
  p.url = 'http://github.com/marklazz/rtt'
  p.author = 'Marcelo Giorgi'
  p.email = 'marklazz.uy@gmail.com'
  p.ignore_pattern = [ 'tmp/*', 'script/*', '*.sh' ]
  p.runtime_dependencies = [
      ['highline', "1.5.2"], ['activerecord', '3.2.6'], ['activesupport', '3.2.6'], ['prawn', '0.8.4'], [ 'rake', '0.8.2' ],
      [ 'allison', '2.0.3'], [ 'extlib', '0.9.15' ], [ 'json_pure', '1.6.5' ], [ 'prawn-core', '0.8.4' ], [ 'prawn-layout', '0.8.4'], ['prawn-security', '0.8.4'],  ['haml', '2.2.24'], ['hanna', '0.1.12'], ['metaclass', '0.0.1'],
      ['rspec', '1.3.0' ], ['mocha', '0.10.4'], ['rubyforge', '2.0.4'], ['rdoc', '2.3.0'], [ 'gemcutter', '0.7.1'], ['echoe', '4.5.6']
   ]
  p.development_dependencies = [ ]
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
