require 'rubygems'
require 'echoe'

# PACKAGING ============================================================

Echoe.new('rtt', '0.0.0.13') do |p|
  p.description = 'RTT is a tool for tracking time'
  p.url = 'http://github.com/marklazz/rtt'
  p.author = 'Marcelo Giorgi'
  p.email = 'marklazz.uy@gmail.com'
  p.ignore_pattern = [ 'tmp/*', 'script/*', '*.sh' ]
  p.runtime_dependencies = [ ['highline', ">= 1.5.2"], ['activesupport', '>= 2.3.0'], ['prawn', '>= 0.8.0'], ['dm-core', '>= 1.0.0'], [ 'dm-migrations', '>= 1.0.0'], 'dm-sqlite-adapter' ]
  p.development_dependencies = [ 'spec' ]
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
