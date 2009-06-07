# -*- coding: utf-8 -*-

require 'rexml/document'
require 'rexml/xpath'
require 'ramaze'
require 'ramaze/spec'

require __DIR__('../start')
Ramaze.options.roots = __DIR__('../')


id = ShuleAroon.options.sproviders.keys[0]

describe MainController do
  behaves_like :rack_test

  def at(doc, xpath)
    REXML::XPath.first(doc, xpath).text
  end

  def match(doc, xpath)
    REXML::XPath.match(doc, xpath)
  end

  def to_doc(body)
    REXML::Document.new(body)
  end

  it 'should show start page' do
    res = get('/')
    res.status.should == 302
    res.headers['Location'].should.include('/bad')
  end

  it 'should show start page with entityID query' do
    values = [id, ShuleAroon.options.sproviders[id][:disc][0], 'entityID']

    doc = to_doc(get('/', :entityID => id).body)
    at(doc, '//div[@id="description"]/h2').should == 'index'
    match(doc, '//form[@id="select_IdP"]//input')[0..2].each_with_index do |e, i|
      e.attributes['value'].should == values[i]
    end
  end

  it 'should show start page with entityID and returnIDParam query' do
    val = 'foo'
    doc = to_doc(get('/', :entityID => id, :returnIDParam => val).body)
    match(doc, '//form[@id="select_IdP"]//input')[2].attributes['value'].should == val
  end

  it 'should show start page with entityID and return query' do
    uri = ShuleAroon.options.sproviders[id][:disc][1]
    doc = to_doc(get('/', :entityID => id, :return => uri).body)
    match(doc, '//form[@id="select_IdP"]//input')[1].attributes['value'].should == uri
  end

  it 'should show start page with entityID and return and isPassive query' do
    uri = ShuleAroon.options.sproviders[id][:disc][1]
    res = get('/', :entityID => id, :return => uri, :isPassive => 'true')
    res.status.should == 302
    res.headers['Location'].should == uri
  end

  it 'should show list page' do
    doc = to_doc(get('/list').body)
    at(doc, '//div[@id="description"]/h2').should == 'list'
    at(doc, '//div[@id="recent_IdP"]//a' ).should == ShuleAroon.options.sproviders[id][:name]
  end

  it 'should show transfer page' do
    doc = to_doc(get('/transfer').body)
    at(doc, '//div[@id="description"]/h2').should == 'no_site'
  end

  it 'should show bad page' do
    res = get('/bad')
    res.status.should == 200
    doc = to_doc(res.body)
    at(doc, '//div[@id="description"]/h2').should == 'bad'
    match(doc, '//span[@class="annotation"]').map do |e|
      e.text
    end.should == ['MUST', 'MAY']
  end
end
