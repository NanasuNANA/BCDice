# -*- coding: utf-8 -*-
require 'diceBot/EclipsePhase'

class EclipsePhase_English < EclipsePhase
  
  setPrefixes(['EP.*'])

  def gameName
    'Eclipse Phase'
  end
  
  def gameType
    'EclipsePhase:English'
  end
  
  def ep_i18n(symbol)
    {
      :CRITICAL_SUCCESS => 'Critical Success',
      :CRITICAL_FAILURE => 'Critical Failure',
      :EXCELLENT => 'Excellent Success',
      :SEVERE => 'Severe Failure',
      :SUCCESS_WITH_MoS => 'Success (MoS of %s)',
      :FAILURE_WITH_MoF => 'Failure (MoF of %s)',
      :EXCELLENT_WITH_MoS_DV => 'Excellent Success (MoS of %1$s), DV+%2$s',
      :SEVERE_WITH_MoF => 'Severe Failure (MoF of %s)',
      :SUCCESS_IF_USE_MOXIE_WITH_MoS => '(Success (MoS of %s), if use the Moxie)',
      :FAILURE_IF_USE_MOXIE_WITH_MoF => '(Failure (MoF of %s), if use the Moxie)',
      :EXCELLENT_IF_USE_MOXIE_WITH_MoS_DV => '(Excellent Success (MoS of %1$s), DV+%2$s, if use the Moxie)',
      :SEVERE_IF_USE_MOXIE_WITH_MoF => '(Severe Failure (MoF of %s), if use the Moxie)',
      :CRITICAL_SUCCESS_IF_USE_MOXIE => '(Critical Success, if use the Moxie)',
      :REGULAR_FAILURE_IF_USE_MOXIE => '(regular Failure, if use the Moxie)'
    }[symbol] || super(symbol)
  end
  
  def getHelpMessage
    return <<INFO_MESSAGE_TEXT
'1D100<=t' style test indicate '#{ep_i18n(:CRITICAL_SUCCESS)}', '#{ep_i18n(:CRITICAL_FAILURE)}', '#{ep_i18n(:EXCELLENT)}' and '#{ep_i18n(:SEVERE)}' automatically, target number (t) allowed to write a formula. also, can use 'EP' and 'EP<=' as shorthand '1D100<=' (ex. 'EP50', 'EP<=14*2+10').
==【License and Credits】=======================
#{license_and_credits.gsub(/[\n\s]+/, ' ').strip}

This dicebot's project page: https://bitbucket.org/Nanasu/dodontohuyong-eclipe-phase-daisubotsuto
INFO_MESSAGE_TEXT
  end
  
  # 英語版ではダイス側の修正は行えない（日本語版では互換性のため残している）
  def check_1D100(total_n, dice_n, signOfInequality, diff, dice_cnt, dice_max, n1, n_max)
    return '' if total_n != dice_n
    super
  end
  
end
