require 'yaml'

class MainController < Ramaze::Controller
  layout '/page'
  helper :aspect, :cgi

  before(:index) {
    redirect Rs(:error) unless request.params['entityID']
  }

  def index
    @list = YAML.load_file('./providers/idp.yaml')
  end

  def clear

  end

  def error

  end
end
