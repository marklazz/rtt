require 'rubygems'
require 'echoe'

# PACKAGING ============================================================

Echoe.new('rtt', '0.1.0') do |p|
  p.description = 'RTT is a tool for tracking time'
  p.url = 'http://'
  p.author = 'Marcelo Giorgi'
  p.email = 'marklazz.uy@gmail.com'
  p.ignore_pattern = [ 'tmp/*', 'script/*' ]
  # p.runtime_dependencies = [ "rupport >= 1.6.4" ]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
