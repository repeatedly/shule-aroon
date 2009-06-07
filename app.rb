# This file contains your application, it requires dependencies and necessary
# parts of the application.
#
# It will be required from either `config.ru` or `start.rb`

require 'rubygems'
require 'ramaze'
require 'ramaze/helper/localize'

# Add the directory this file resides in to the load path, so you can run the
# app from any other working directory
$LOAD_PATH.unshift(__DIR__)


# ShuleAroon configration
module ShuleAroon
  include Ramaze::Optioned

  options.dsl do
    path   = File.expand_path(File.dirname(__FILE__))
    config = YAML.load_file(File.join(path, './conf/ds.yaml'))

    o 'Domain of trust circle', :common_domain,
      config[:common_domain]

    o 'Expires of permanet cookie', :expires,
      config[:expires] || (3600 * 24 * 365)

    sub :admin do
      o 'Admin name', :name,
        config[:admin]

      o 'Admin e-mail', :mail,
        config[:mail]
    end

    sub :federation do
      o 'Federation name', :name,
        config[:fed_name]

      o 'Federation link', :link,
        config[:fed_link]
    end

    o 'SP list', :sproviders,
      YAML.load_file(File.join(path, './conf/sp.yaml'))

    o 'IdP list', :idproviders,
      YAML.load_file(File.join(path, './conf/idp.yaml'))

    # for Localize
    dictionary = Ramaze::Helper::Localize::Dictionary.new
    Dir.glob('./conf/locale/*.yaml').each do |f|
      dictionary.load(File.basename(f, '.yaml').intern , :yaml => f)
    end

    o 'Dictionary for Helper::Localize', :dictionary,
      dictionary

    # Don't edit below
    o 'Name of common domain cookie', :common_domain_cookie,
      '_saml_idp'

    o 'Name of redirect cookie for IdP', :redirect_cookie,
      '_redirect_idp'

    Ramaze.options.adapter.handler = config[:handler]
    Ramaze.options.adapter.port    = config[:port]
  end
end

# 10 files history, 5 MB each
# Ramaze::Log.loggers << Logger.new('./log/ds.log', 10, (5 << 20))

# Initialize controllers and models
require 'controller/main'
