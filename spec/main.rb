# -*- coding: utf-8 -*-
require 'spec_helper'

conf  = Ramaze::Global.ds_config
lang  = conf[:default_language]
local = Ramaze::Tool::Localize.method(:localize)
sp_id = Ramaze::Global.SProviders.keys[0]

describe MainController do
  behaves_like 'http', 'xpath'
  ramaze :view_root   => __DIR__('view'),
         :public_root => __DIR__('public')

  it 'should show start page' do
    res = get('/')
    res.status.should == 302
    res.headers['Location'].should == '/bad'
  end

  it 'should show start page with entityID query' do
    values = [sp_id, Ramaze::Global.SProviders[sp_id][:disc][0], 'entityID']

    res = get('/', :entityID => sp_id)
    res.at('//div[@id="description"]/h2').text.strip.should == local.call('index', lang)
    res.match('//form[@id="select_IdP"]//input')[0..2].each_with_index do |e, i|
      e.attributes['value'].should == values[i]
    end
  end

  it 'should show start page with entityID and returnIDParam query' do
    val = 'foo'
    res = get('/', :entityID => sp_id, :returnIDParam => val)
    res.match('//form[@id="select_IdP"]//input')[2].attributes['value'].should == val
  end

  it 'should show start page with entityID and return query' do
    uri = Ramaze::Global.SProviders[sp_id][:disc][1]
    res = get('/', :entityID => sp_id, :return => uri)
    res.match('//form[@id="select_IdP"]//input')[1].attributes['value'].should == uri
  end

  it 'should show start page with entityID and return and isPassive query' do
    uri = Ramaze::Global.SProviders[sp_id][:disc][1]
    res = get('/', :entityID => sp_id, :return => uri, :isPassive => 'true')
    res.status.should == 302
    res.headers['Location'].should == uri
  end

  it 'should show list page' do
    res = get('/list')
    res.at('//div[@id="description"]/h2').text.strip.should == local.call('list', lang)
    res.at('//div[@id="recent_IdP"]//a' ).text.strip.should == Ramaze::Global.SProviders[sp_id][:name]
  end

  it 'should show transfer page' do
    res = get('/transfer')
    res.at('//div[@id="description"]/h2').text.strip.should == local.call('no_site', lang)
  end

  it 'should show bad page' do
    res = get('/bad')
    res.status.should == 200
    res.at('//div[@id="description"]/h2').text.strip.should == local.call('bad', lang)
    res.match('//span[@class="annotation"]').map do |e|
      e.text
    end.should == ['MUST', 'MAY']
  end
end
