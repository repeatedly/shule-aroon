#!/usr/bin/env ruby

%w[rubygems ramaze yaml uri].each do |lib|
  require lib
end

# Measure for deamonize.
Dir.chdir(__DIR__)

ds_config = YAML.load_file('./conf/ds.yaml')

unless Ramaze::Log.loggers.size == 2
  Ramaze::Log.loggers <<
    Ramaze::Logging::Logger::Informer.new("log/ds_#{Time.now.strftime('%Y%m%d')}.log",
                                          ds_config[:log_level])
end

Ramaze::Global.add_option(:ds_config,   ds_config)
Ramaze::Global.add_option(:SProviders,  YAML.load_file('./conf/sp.yaml'))
Ramaze::Global.add_option(:IdProviders, YAML.load_file('./conf/idp.yaml'))

require 'controller/main'

Ramaze.start :adapter => ds_config[:adapter], :port => ds_config[:port]
