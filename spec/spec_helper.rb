require 'ramaze'
require 'ramaze/spec/helper'

# for external file
Ramaze::Global.root = File.join(Ramaze::Global.root, '..')

require __DIR__('../start')
