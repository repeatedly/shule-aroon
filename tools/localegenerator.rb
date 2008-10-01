#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

begin
  $KCODE = 'u'
  require 'rubygems' rescue nil
  require 'ya2yaml'
  [Object, Hash].each do |klass|
    klass.class_eval { alias to_yaml ya2yaml }
  end
rescue LoadError
  require 'yaml'
end


class LocaleGenerator
  Keywords = [
  # common(0 - 5)
  'recent', 'legend', 'select', 'info', 'admin', 'mail',
  # index(6 - 11)
  'index', 'index_text', 'clear', 'bypass', 'remember', 'permanent',
  # transfer(12 - 15)
  'transfer', 'transfer_text', 'no_site', 'no_site_text',
  # bad(16 - 18)
  'bad', 'bad_text', 'bad_warn',
  # error(19 - 20)
  'err', 'err_text',
  # flash(21 - 25)
  'not_SAML', '404_RP', '404_DS', '404_idpdisc', 'invalid_URI'
  ]

  Message = {
    # English
    :en => [
    # common
    'Recently selected Identity Provider.',
    'Identity Provider List',
    'Select',
    'Contact Information',
    'Admin',
    'Mail',
    # index
    'Select your Identity Provider',
    'Select from following IdP list.',
    'Clear',
    'DS bypass configuration(for single IdP user)',
    'Remember this selection while closing browser.',
    'Remember this selection permanently.',
    # transfer
    'Select your password change site',
    'Select from following IdP list for Password change.',
    'No entries.',
    'Password change sites don\'t exist Identity Providers.',
    # bad
    'Bad request!',
    'Require parameters are following. ',
    'Please contact administrator if display this page in an orderly manner. ',
    # error
    'Error!',
    'Please contact administrator.',
    # flash
    'Request parameters are different from SAML spec.',
    'SP is not found in Relying Party.',
    'DS end point must be require.',
    "'return' parameter is not found in Metadata.",
    "'return' parameter is invalid URI"
    ],
    # Japanese
    :jp => [
    #common
    '最近選択したIdentity Provider.',
    'Identity Provider リスト',
    '送信',
    '連絡先',
    '管理者',
    'メールアドレス',
    # index
    'Identity Providerを選択して下さい',
    '下記のリストからIdPを選択して下さい.',
    'クリア',
    'DSの迂回設定(単一IdPユーザ向け).',
    'ブラウザを閉じるまで選択を保存する.',
    'これからずっと選択を保存する.',
    # transfer
    'パスワード変更サイトを選択して下さい.',
    'パスワード変更のため下記のリストからIdPを選択して下さい.',
    'エントリがありません.',
    'IdPの中にパスワード変更サイトが登録されていません.',
    # bad
    '不正なリクエストです!',
    '必要なパラメータは下記の通りです. ',
    'もし正しい操作でこのページが表示されたのなら，管理者へと連絡して下さい. ',
    # error
    'エラー!',
    '管理者へと連絡して下さい.',
    # flash
    'リクエストパラメータがSAML仕様と異なっています.',
    'SPがRelying Partyに見つかりません.',
    'DSのエンドポイントは必須です.',
    'Metadataにreturnパラメータの値が見つかりません.',
    'returnパラメータの値が不正なURIです.'
    ]
  }

  Dictionary = Hash.new { |h, k| h[k] = {} }
  Message.each_pair do |lang, value|
    Keywords.each_with_index do |key, i|
      Dictionary[lang][key] = value[i]
    end
  end

  def self.exec(path = '')
    Dictionary.each do |lang, dic|
      File.open(path + "#{lang}.yaml", 'w') { |f|
        f.print(dic.to_yaml)
      }
    end
  end

  def self.example
    Dictionary[:en]
  end
end


if $0 == __FILE__
  path = ARGV.empty? ? '../conf/locale/' : ARGV.first
  LocaleGenerator.exec(path)
end
