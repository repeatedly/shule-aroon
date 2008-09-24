require 'rubygems'
require 'ramaze'

Ramaze::Global.sessions = false

# require all controllers and models
acquire __DIR__/:controller/'*'

Ramaze.start :adapter => :webrick, :port => 7000
