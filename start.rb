require 'rubygems'
require 'ramaze'
require 'yaml'

Ramaze::Global.sessions = false

# Measure for deamonize.
Dir.chdir(__DIR__)

unless Ramaze::Log.loggers.size == 2
  Ramaze::Log.loggers <<
    Ramaze::Logging::Logger::Informer.new("log/ds_#{Time.now.strftime('%Y%m%d')}.log")
end

#Ramaze::Global.add_option(:ds_config,   YAML.load_file('./conf/ds.yaml'))
Ramaze::Global.add_option(:SProviders,  YAML.load_file('./conf/sp.yaml'))
Ramaze::Global.add_option(:IdProviders, YAML.load_file('./conf/idp.yaml'))

require 'controller/main'

Ramaze.start :adapter => :mongrel, :port => 7000
