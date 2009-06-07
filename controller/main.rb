# -*- coding: utf-8 -*-

class MainController < Ramaze::Controller
  layout :default
  helper :localize
  engine :Etanni

  before_all {
    @config = ShuleAroon.options
    @params = request.params
  }

  def index
    check_request

    if @params['select_IdP']
      entity_id = @params['user_IdP']
      set_common_domain_cookie(entity_id)
      set_redirect_cookie(entity_id) if @params['bypass']
      redirect build_uri(entity_id)
    else
      check_sp(@params['entityID'])
    end
  end

  #
  # Clears the common domain cookie.
  #
  def clear
    response.delete_cookie(@config.common_domain_cookie)
    redirect r('?' + @params['query'])
  end

  #
  # Transfers the user to Password change site.
  #
  def transfer
    redirect @params['user_IdP'] if @params['user_IdP']

    if entity_id = request.cookies[@config.redirect_cookie]
      if site_url = get_attribute(entity_id)[:site]
        redirect site_url
      end
    end
  end

  #
  # for Localize filter
  #
  alias :raw_wrap_action_call :wrap_action_call

  def wrap_action_call(action, &block)
    localize(raw_wrap_action_call(action, &block))
  end

  private

  #
  # Returns the redirect URI to SP
  #
  def build_uri(entity_id)
    uri  = @params['return'].dup
    uri << "&#{returnIDParam}=#{entity_id}"
  end

  #
  # Checks GET request.
  # Refer to [IdP Discovery Protocol 2.4.1].
  #
  def check_request
    if not @params['entityID'] or @params['entityID'].empty?
      bad_request('Request parameters are different from SAML.')
    elsif @params['isPassive'] == 'true'
      redirect @params['return']
    elsif request.cookies[@config.redirect_cookie]
      redirect build_uri(request.cookies[@config.redirect_cookie])
    end
  end

  #
  # Checks SP's entityID and return parameter.
  # Refer to [IdP Discovery Protocol 2.5].
  #
  def check_sp(entity_id)
    # Not include Relying Parties.
    unless @config.sproviders.key?(entity_id)
      bad_request('SP is not found in Relying Party.')
    end

    end_point = get_end_point(@params['return'])
    sprovider = @config.sproviders[entity_id]

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
      bad_request("'return' parameter is not found in Metadata.")
    end
  end

  #
  # Returns DS end point URI from 'return' parameter.
  # This return value is used to compare idpdisc 'Location'.
  #
  def get_end_point(return_uri)
    return nil unless return_uri

    uri = URI.split(return_uri)
    uri[0] + '://' + uri[2] + (uri[3] || '') + uri[5]
  rescue
    bad_request("'return' paratemer is invalid URI")
  end

  #
  # Redirects bad page and set the flash message.
  #
  def bad_request(msg)
    flash[:msg] = msg
    Ramaze::Log.warn(msg)
    redirect r(:bad)
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
  # Returns _entity_id_ attribute of idp.yaml.
  #
  def get_attribute(entity_id)
    @config.idproviders.each_pair do |fed_name, idp|
      if idp.key?(entity_id)
        return idp[entity_id]
      end
    end
    nil
  end

  #
  # Returns recently selected and other IdP list that existing :site section.
  #
  def get_sites(entity_ids)
    recent, others = {}, Hash.new { |h, k| h[k] = {} }

    @config.idproviders.each do |fed_name, idp|
      idp.each_pair do |entity_id, value|
        if value.key?(:site)
          if entity_ids and entity_ids.include?(entity_id)
            recent[entity_id]        = {}
            recent[entity_id][:site] = value[:site]
            recent[entity_id][:name] = value[:name] || entity_id
          else
            others[fed_name][entity_id]        = {}
            others[fed_name][entity_id][:site] = value[:site]
            others[fed_name][entity_id][:name] = value[:name] || entity_id
          end
        end
      end
    end

    recent = recent.empty? ? nil : recent
    others = others.empty? ? nil : others
    return recent, others
  end

  #
  # Set the common domain cookie.
  # Refer to [SAML Profile 2.0 4.3.1, 4.3.2]
  #
  def set_common_domain_cookie(idp)
    cdk = if cdk = get_common_domain_cookie
            cdk.delete(idp)
            cdk.unshift(idp)
            cdk = cdk.map { |idp| [idp].pack('m') }.join(' ')
          else
            [idp].pack('m')
          end
    response.set_cookie(@config.common_domain_cookie, create_cookie(cdk))
  end

  #
  # Parse and get the common domain cookie.
  # Refer to [SAML Profile 2.0 4.3.1, 4.3.3]
  #
  def get_common_domain_cookie
    if cdk = request.cookies[@config.common_domain_cookie]
      cdk.split(/ /).map { |id| id.unpack('m')[0] }
    else
      nil
    end
  end

  #
  # Set the cookie using bypass this Discovery Service.
  #
  def set_redirect_cookie(idp)
    response.set_cookie(@config.redirect_cookie, create_cookie(idp))
  end

  def create_cookie(value)
    cookie = {
      :value  => value,
      :domain => @config.common_domain
    }
    cookie[:expires] = Time.now + @config.expires if @params['bypass'] == 'permanent'
    cookie
  end

  #
  # for Helper::Localize
  #
  def localize_dictionary
    @config.dictionary
  end
end
