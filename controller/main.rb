require 'yaml'

class MainController < Ramaze::Controller
  layout '/page'
  helper :aspect

  before(:index) {
    if entity_id = request.cookies['_redirect_idp']
      auto_redirect(entity_id)
    end
    #redirect Rs(:error) unless request.params['entityID']
  }

  def index
    @params = request.params
    @list   = YAML.load_file('./conf/idp.yaml')
    @cdk    = get_cdk

    if @params['select_IdP']
      entity_id = @params['user_IdP']
      set_cdk(entity_id)
      set_redirect_cookie(entity_id) if @params['remember']
      redirect  build_url(entity_id)
    end

    set_cdk('')
  end

  private

  def build_url(entity_id)
    url  = request.params['return'].dup
    url << "&#{returnIDParam}=#{entity_id}"
  end

  def check_sp

  end

  #
  # Returns 'entityID' if returnIDParam is empty.
  # Refer to [IdP Discovery Protocol 2.4.1]. 
  #
  def returnIDParam
    return_id = request.params['returnIDParam']
    if return_id and not return_id.empty?
      return_id
    else
      'entityID'
    end
  end

  def display_name(entity_id)
    @list.each_pair do |fed_name, idp|
      if idp.has_key?(entity_id)
        return idp[entity_id][:name] || entity_id
      end
    end
    entity_id
  end

  def auto_redirect(entity_id)
    set_cdk(entity_id)
    redirect build_url(entity_id)
  end

  #-
  # cdk is common domain cookie
  #+

  def set_cdk(idp)
    cdk = if cdk = get_cdk and not cdk.empty?
            p cdk
            cdk.delete(idp)
            cdk.unshift(idp)
            cdk = cdk.map { |idp| [idp].pack('m') }.join(' ')
          else
            [idp].pack('m')
          end
    p cdk
    response.set_cookie('_saml_idp', cdk)
  end

  def get_cdk
    if cdk = request.cookies['_saml_idp']
      cdk.split(' ').map { |id| id.unpack('m')[0] }
    else
      nil
    end
  end

  def set_redirect_cookie(idp)
    response.set_cookie('_redirect_idp', idp)
  end
end
