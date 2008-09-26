# -*- coding: utf-8 -*-

class MainController < Ramaze::Controller
  layout '/page'
  helper :aspect

  before(:index) {
    @params = request.params
    check_request
    check_sp(@params['entityID'])
  }

  def index
    if @params['select_IdP']
      entity_id = @params['user_IdP']
      set_cdk(entity_id)
      set_redirect_cookie(entity_id) if @params['remember']
      redirect  build_url(entity_id)
    end
  end

  private

  def build_url(entity_id)
    url  = @params['return'].dup
    url << "&#{returnIDParam}=#{entity_id}"
  end

  #
  # Checks GET request.
  # Refer to [IdP Discovery Protocol 2.4.1].
  #
  def check_request
    if not @params['entityID']
      bad_request('Access parameters are different from SAML spec.')
    elsif @params['isPassive'] == 'true'
      redirect @params['return']
    elsif request.cookies['_redirect_idp']
      redirect build_url(request.cookies['_redirect_idp'])
    end
  end

  #
  # Checks SP's entityID and return parameter.
  # Refer to [IdP Discovery Protocol 2.5].
  #
  def check_sp(entity_id)
    # Not include Relying Parties.
    unless Ramaze::Global.SProviders.key?(entity_id)
      bad_request("SP is not found in Relying Party.")
    end

    end_point = get_end_point(@params['return'])
    sprovider = Ramaze::Global.SProviders[entity_id]

    # Case of 'return' parameter nothing.
    unless end_point
      # idpdisc MUST be present.
      if sprovider.key?(:disc)
        @params['return'] = sprovider[:disc][0]
        return
      else
        bad_request('DS end point must be require.')
      end
    end

    # Case of 'return' parameter existing.
    if sprovider.key?(:disc) and
        not sprovider[:disc].include?(end_point)
      bad_request("'return' value is not found in Metadata.")
    end
  end

  #
  # Returns DS end point URL from 'return' parameter.
  # This return value is used to compare idpdisc 'Location'.
  #
  def get_end_point(return_url)
    return nil unless return_url

    require 'uri'
    uri = URI.parse(return_url) rescue bad_request("End point URL is invaid.")
    uri.scheme + '://' + uri.host + uri.path
  end

  #
  # Redirects bad page and set the flash message.
  #
  def bad_request(msg)
    flash[:msg] = msg
    redirect Rs(:bad)
  end

  #
  # Returns parameter name used to return the entityID of user selected IdP.
  # Returns 'entityID' if returnIDParam is empty.
  # Refer to 'returnIDParam' section of [IdP Discovery Protocol 2.4.1]. 
  #
  def returnIDParam
    return_id = @params['returnIDParam']
    if return_id and not return_id.empty?
      return_id
    else
      'entityID'
    end
  end

  #
  # Returns display name existing name section of idp.yaml.
  # This method is used, when existing the common domain cookie.
  #
  def display_name(entity_id)
    Ramaze::Global.IdProviders.each_pair do |fed_name, idp|
      if idp.key?(entity_id)
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
      cdk.split(/ /).map { |id| id.unpack('m')[0] }
    else
      nil
    end
  end

  def set_redirect_cookie(idp)
    response.set_cookie('_redirect_idp', idp)
  end
end
