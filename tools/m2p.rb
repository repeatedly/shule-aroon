#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#
# = m2p.rb: Metadata to Providers tool
#
# Author:: Tama <repeatedly@gmail.com>
#
# M2P generates the YAML files for Ruby-DS.
#
# == Example
#
#   M2P.exec(Dir.glob('./*.xml'))
#
# == CLI
#
# Default convert files is 'dsroot/metadata/*.xml'.
# Pass the argument if you would like to change the seach path.
#
#   ruby m2p.rb ./foo.xml ../metadata/bar.xml
#
# Saved path and file name can't change.
#
# == Format
#
# === Metadata
#
# Metadata format is the SAML Metadata.
#
# === YAML
#
# +idp.yaml+ is following format.
# Display name is the Metadata's file name replaced '_' with ' '
# (e.g. Example_Fedaration.xml => Example Fedaration).
# :name is optional value if OrganizationDisplayName exists as element.
#
#   Example Federation: 
#     https://idp.example.org/idp/shibboleth: 
#       :SSO: https://idp.example.org/idp/profile/Shibboleth/SSO
#       :name: Your Identities
#
# +sp.yaml+ is following format.
# sp.yaml not present Display name.
# :disc is optional value if idpdisc:DiscoveryResponse exists as element.
#
#   https://sp.example.org/shibboleth-sp: 
#     :disc: 
#     - http://sp.example.org/Shibboleth.sso/DS
#     - https://sp.example.org/Shibboleth.sso/DS
#


$KCODE = 'u' if RUBY_VERSION < '1.9.0'


require 'kconv'
require 'yaml'
require 'rexml/document'


class M2P
  MetadataSuffix = '.xml'
  SearchElements = {
    :Entities => 'EntitiesDescriptor',
    :Entity   => 'EntityDescriptor',
    :IdP      => 'IDPSSODescriptor',
    :IdPSSO   => 'IDPSSODescriptor/SingleSignOnService',
    :Display  => 'Organization/OrganizationDisplayName',
    :SPDisc   => 'SPSSODescriptor/Extensions/idpdisc:DiscoveryResponse',
    :Binding  => 'urn:mace:shibboleth:1.0:profiles:AuthnRequest'
  }

  #
  # Converts and saves file.
  #
  def self.exec(files)
    M2P.new(files).convert.save
  end

  #
  # _files_ is array having metadata's path.
  #
  def initialize(files)
    @metadata    = files
    @IdProviders = Hash.new { |h, k| h[k] = {} }
    @SProviders  = Hash.new
  end

  attr_reader :IdProviders, :SProviders

  #
  # Metadata to Providers Hash.
  #
  def convert
    @metadata.each do |metadata|
      name = File.basename(metadata, MetadataSuffix).gsub('_', ' ')
      doc  = get_document(metadata)
      parse_metadata(doc.root, name)
    end
    self
  end

  #
  # Saved files are 'idp.yaml' and 'sp.yaml'.
  #
  def save
    File.open('idp.yaml', 'w') { |f| f.print @IdProviders.to_yaml }
    File.open('sp.yaml',  'w') { |f| f.print @SProviders.to_yaml  }
  end

  private

  #
  # Metadata to XML document encoded utf-8.
  #
  def get_document(metadata)
    doc = nil
    File.open(metadata, 'r') { |f| doc = REXML::Document.new(Kconv.toutf8(f.read)) }
    doc
  end

  #
  # Parses the metadata that recursively-defined EntitiesDescriptor.
  #
  def parse_metadata(doc, name)
    idp, sp = [], []

    doc.each_element(SearchElements[:Entity]) do |elem|
      unless elem.get_elements(SearchElements[:IdP]).empty?
        idp << elem
      else
        sp  << elem
      end
    end

    @IdProviders[name].merge!(parse_idp(idp))
    @SProviders.merge!(parse_sp(sp))

    doc.each_element(SearchElements[:Entities]) do |elem|
      parse_metadata(elem, name)
    end
  end

  #
  # Sets IdP elements to hash.
  #
  def parse_idp(elements)
    providers = {}

    elements.each do |elem|
      entity_id = elem.attributes['entityID']
      providers[entity_id] = {}

      elem.get_elements(SearchElements[:IdPSSO]).each do |sso|
        if sso.attributes['Binding'] == SearchElements[:Binding]
          providers[entity_id][:SSO] = sso.attributes['Location']
          break
        end
      end

      set_name(elem, providers[entity_id])
    end

    providers
  end

  #
  # Sets SP elements to hash.
  #
  def parse_sp(elements)
    providers = {}

    elements.each do |elem|
      entity_id = elem.attributes['entityID']
      providers[entity_id] = {}

      elem.get_elements(SearchElements[:SPDisc]).each do |ds|
        providers[entity_id][:disc] ||= []
        providers[entity_id][:disc] << ds.attributes['Location']
      end

      #set_name(elem, providers[entity_id])
    end

    providers
  end

  #
  # Sets the display name if OrganizationDisplayName element exist.
  #
  def set_name(element, provider)
    org_name = element.get_elements(SearchElements[:Display])
    provider[:name] = org_name[0].text unless org_name.empty?
  end
end


# for CLI
if $0 == __FILE__
  files = ARGV.empty? ? Dir.glob('../metadata/*.xml') : ARGV
  M2P.exec(files)
end
