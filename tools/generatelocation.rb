#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'ramaze'
require 'ya2yaml'

class GenerateLocation
  Dict = {
    :en => {
      #common
      'main'   => 'Select your Identity Provider',
      'recent' => 'Recently selected Identity Provider.',
      'legend' => 'Identity Provider List',
      'select' => 'Select',
      'info'   => 'Contact Info',
      'admin'  => 'Admin',
      'mail'   => 'Mail',

      # index
      'index'     => 'Select from following IdP list.',
      'clear'     => 'Clear',
      'bypass'    => 'DS bypass configuration.',
      'remember'  => 'Remember this selection while closing browser.',
      'permanent' => 'Remember this selection permanently.',

      # transfer
      'no_desc' => 'No entries.',
      'no_text' => 'Password change sites don\'t exist Identity Providers.',
      'trans'   => 'Select from following IdP list for Password change.',

      # bad
      'bad'      => 'Bad request!',
      'bad_text' => 'Require parameters are following. ',
      'bad_warn' => 'Please contact administrator if display this page in an orderly manner. ',

      # error
      'err'      => 'Error!',
      'err_text' => 'Please contact administrator.'
    },
    :jp => {
      #common
      'main'   => 'Identity Providerを選択して下さい',
      'recent' => '最近選択したIdentity Provider.',
      'legend' => 'Identity Provider リスト',
      'select' => '送信',
      'info'   => '連絡先',
      'admin'  => '管理者',
      'mail'   => 'メールアドレス',

      # index
      'index'     => '下記のリストからIdPを選択して下さい.',
      'clear'     => 'クリア',
      'bypass'    => 'DSの迂回設定.',
      'remember'  => 'ブラウザを閉じるまで選択を保存する.',
      'permanent' => 'これからずっと選択を保存する.',

      # transfer
      'no_desc' => 'エントリがありません.',
      'no_text' => 'IdPの中にパスワード変更サイトが登録されていません.',
      'trans'   => 'パスワード変更のため下記のリストからIdPを選択して下さい.',

      # bad
      'bad'      => '不正なリクエストです!',
      'bad_text' => '必要なパラメータは下記の通りです. ',
      'bad_warn' => 'もし正しい操作でこのページが表示されたのなら，管理者へと連絡して下さい. ',

      # error
      'err'      => 'エラー!',
      'err_text' => '管理者へと連絡して下さい.'
    }
  }

  def self.exec(path = nil)
    dir = nil || __DIR__/'..'/:conf
    Dict.each do |lang, dic|
      File.open(dir/"locale_#{lang}.yaml", 'w') { |f|
        f.print(dic.to_yaml)
      }
    end
  end
end

if $0 == __FILE__
  GenerateLocation.exec
end
