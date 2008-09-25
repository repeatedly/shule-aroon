# -*- coding: utf-8 -*-

class MainController < Ramaze::Controller
  layout '/page'
  helper :aspect

  before(:index) {
    check_access
    check_sp
  }

  def index
    @params = request.params

    if @params['select_IdP']
      entity_id = @params['user_IdP']
      set_cdk(entity_id)
      set_redirect_cookie(entity_id) if @params['remember']
      redirect  build_url(entity_id)
    end
  end

  private

  def build_url(entity_id)
    url  = request.params['return'].dup
    url << "&#{returnIDParam}=#{entity_id}"
  end

  #
  # Checks HTTP GET request.
  # Refer to [IdP Discovery Protocol 2.4.1].
  #
  def check_access
    if not request.params['entityID']
      redirect Rs(:bad)
    elsif request.cookies['_redirect_idp']
      redirect build_url(request.cookies['_redirect_idp'])
    elsif request.params['isPassive'] == 'true'
      redirect request.params['return']
    end
  end

  #
  # Checks SP's entityID and return URL if use metadata.
  # Refer to [IdP Discovery Protocol 2.5].
  #
  def check_sp
    entity_id =  request.params['entityID']

    redirect Rs(:bad) unless Ramaze::Global.SProviders.has_key?(entity_id)
    #redirect Rs(:bad) unless search_ds_url(entity_idrequest.params['return'])
  end

  #
  # Returns User DS end point URL.
  #
  def search_ds_url
    
  end

  #
  # Returns 'entityID' if returnIDParam is empty.
  # Refer to 'returnIDParam' section of [IdP Discovery Protocol 2.4.1]. 
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
    Ramaze::Global.IdProviders.each_pair do |fed_name, idp|
      if idp.has_key?(entity_id)
        return idp[entity_id][:name] || entity_id
      end
    end
    entity_id
  end

  #-
  # cdk is common domain cookie.
  #+

  def set_cdk(idp)
    cdk = if cdk = get_cdk
            cdk.delete(idp)
            cdk.unshift(idp)
            cdk = cdk.map { |idp| [idp].pack('m') }.join(' ')
          else
            [idp].pack('m')
          end
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
