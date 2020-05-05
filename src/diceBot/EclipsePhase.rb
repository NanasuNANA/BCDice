# -*- coding: utf-8 -*-
class EclipsePhase < DiceBot

  setPrefixes(['EP.*'])

  # ゲームシステムの識別子
  ID = 'EclipsePhase'

  # ゲームシステム名
  NAME = 'エクリプス・フェイズ'

  # ゲームシステム名の読みがな
  SORT_KEY = 'えくりふすふえいす'
  
  def license_and_credits
    <<-EOS
    
      Eclipse Phase is a trademark of Posthuman Studios, LLC. Some Rights Reserved. 
      Eclipse Phase products (including printed rulebooks/sourcebooks and PDFs) by Posthuman Studios 
      (http://eclipsephase.com) are licensed under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 License 
      (https://creativecommons.org/licenses/by-nc-sa/3.0/), with certain exceptions. 
      See CC licensing page (http://eclipsephase.com/cclicense) on eclipsephase.com for detail. 
    
    EOS
  end
  
  def gameName
    'エクリプス・フェイズ'
  end
  
  def gameType
    'EclipsePhase'
  end
  
  # 別言語版を作る場合サブクラスで実装
  def ep_i18n(symbol)
    {
      :CRITICAL_SUCCESS => '決定的成功',
      :CRITICAL_FAILURE => '決定的失敗',
      :EXCELLENT => 'エクセレント',
      :SEVERE => 'シビア',
      :SUCCESS_WITH_MoS => '成功（成功度%s）',
      :FAILURE_WITH_MoF => '失敗（失敗度%s）',
      :EXCELLENT_WITH_MoS_DV => 'エクセレント（成功度%1$s） DV+%2$s',
      :SEVERE_WITH_MoF => 'シビア（失敗度%s）',
      :SUCCESS_IF_USE_MOXIE_WITH_MoS => '（勇気を使用した場合、成功度%s）',
      :FAILURE_IF_USE_MOXIE_WITH_MoF => '（勇気を使用した場合、失敗度%s）',
      :EXCELLENT_IF_USE_MOXIE_WITH_MoS_DV => '（勇気を使用した場合、エクセレント（成功度%1$s） DV+%2$s）',
      :SEVERE_IF_USE_MOXIE_WITH_MoF => '（勇気を使用した場合、シビア（失敗度%s））',
      :CRITICAL_SUCCESS_IF_USE_MOXIE => '（勇気を使用した場合、決定的成功）',
      :REGULAR_FAILURE_IF_USE_MOXIE => '（勇気を使用した場合、通常の失敗）'
    }[symbol]
  end
  
  def getHelpMessage
    return <<INFO_MESSAGE_TEXT
1D100<=m 方式の判定で成否、#{ep_i18n(:CRITICAL_SUCCESS)}、#{ep_i18n(:CRITICAL_FAILURE)}、#{ep_i18n(:EXCELLENT)}、#{ep_i18n(:SEVERE)}を自動判定、mに四則演算使用可能。また、'1D100<='の略記として'EP'、'EP<='を使用可能（例：EP50、EP<=14*2+10）。
注）目標値mではなくダイス側を修正する場合、符号を反転した目標値への修正と同様に機能するが、掛け算、割り算では動作未定義。
==【License and Credits】=======================
#{license_and_credits.gsub(/[\n\s]+/, ' ').strip}
　
日本語ダイスボット中の訳語は『エクリプス・フェイズ』（ISBN 9784775310229、朱鷺田祐介 監訳、『エクリプス・フェイズ』翻訳チーム 訳、新紀元社。書誌は国立国会図書館のものより抜粋）より。
このダイスボットは https://bitbucket.org/Nanasu/dodontohuyong-eclipe-phase-daisubotsuto で公開されています。
INFO_MESSAGE_TEXT
  end
  
  def help_message
    getHelpMessage
  end
  
  # ()なしで目標値側の修正を行えるように追加
  def changeText(string)
    string.sub(/EP((<=)?[\d\(\+\-])/i, '1D100<=\1').sub(/(=|<|>|<=|>=)([\d\+\-][\d\+\-\*\/\(\)]*)/) {"#{$1}#{parren_killer('(0' + $2 + ')')}"}
  end
  
  def check_1D100(total_n, dice_n, signOfInequality, diff)

    return '' unless signOfInequality == :<=
    
    diceValue = dice_n % 100 # 出目00は100ではなく00とする
    dice_ten_place = diceValue / 10
    dice_one_place = diceValue % 10
    
    debug('dice_n', dice_n)
    debug('dice_ten_place, dice_one_place', dice_ten_place, dice_one_place)
    
    if dice_ten_place == dice_one_place
      return " ＞ 00 ＞ #{ep_i18n(:CRITICAL_SUCCESS)}" if diceValue == 0
      return " ＞ #{ep_i18n(:REGULAR_FAILURE_IF_USE_MOXIE)} ＞ #{ep_i18n(:CRITICAL_FAILURE)}" if diceValue == 99
      return " ＞ #{ep_i18n(:CRITICAL_SUCCESS)}" if total_n <= diff
      return " ＞ #{ep_i18n(:REGULAR_FAILURE_IF_USE_MOXIE)} ＞ #{ep_i18n(:CRITICAL_FAILURE)}"
    end
    
    mof = total_n - diff
    swaps = dice_one_place * 10 + dice_ten_place
    total_swaps = swaps + total_n - dice_n
        
    # ダイスではなく目標値側を修正するルールだが、利便のため目標値側のプラス修正とダイス側のマイナス修正（あるいはその逆）は意味が同じであるように実装
    if total_n <= diff
      if dice_n >= 30
        " ＞ #{ep_i18n(:CRITICAL_SUCCESS_IF_USE_MOXIE)} ＞ #{sprintf(ep_i18n(:EXCELLENT_WITH_MoS_DV), dice_n, dice_n >= 60 ? 10 : 5)}"
      else
        " ＞ #{ep_i18n(:CRITICAL_SUCCESS_IF_USE_MOXIE)} ＞ #{ep_i18n(:SUCCESS_WITH_MoS) % dice_n}"
      end
    else
      if swaps < dice_n
        if total_swaps <= diff
          if swaps >= 30
            " ＞ #{sprintf(ep_i18n(:EXCELLENT_IF_USE_MOXIE_WITH_MoS_DV), swaps, swaps >= 60 ? 10 : 5)}"
          else
            " ＞ #{ep_i18n(:SUCCESS_IF_USE_MOXIE_WITH_MoS) % swaps}"
          end
        elsif total_swaps - diff < 30
          " ＞ #{ep_i18n(:FAILURE_IF_USE_MOXIE_WITH_MoF) % (total_swaps - diff)}"
        else
          " ＞ #{ep_i18n(:SEVERE_IF_USE_MOXIE_WITH_MoF) % (total_swaps - diff)}"
        end
      else
        ''
      end + if total_n - diff < 30
        " ＞ #{ep_i18n(:FAILURE_WITH_MoF) % (total_n - diff)}"
      else
        " ＞ #{ep_i18n(:SEVERE_WITH_MoF) % (total_n - diff)}"
      end
    end
  end
  
end
