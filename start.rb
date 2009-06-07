# Use this file directly like `ruby start.rb` if you don't want to use the
# `ramaze start` command.
# All application related things should go into `app.rb`, this file is simply
# for options related to running the application locally.

require File.expand_path('app', File.dirname(__FILE__))
adapter = Ramaze.options.adapter
Ramaze.start(:adapter => adapter.handler, :port => adapter.port, :file => __FILE__)
