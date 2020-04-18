#--*-coding:utf-8-*--

class SRSCustom < DiceBot
  setPrefixes(['.*L.*', '.*F.*'])
  
  # ゲームシステムの識別子
  ID = 'SRSCustom'

  # ゲームシステム名
  NAME = 'SRS汎用(改造版)'

  # ゲームシステム名の読みがな
  SORT_KEY = 'SRS汎用(改造版)'

  
  def initialize
    super
    @d66Type = 1
  end
  
  def gameName
    'SRS汎用(改造版)'
  end
  
  def gameType
    "SRSCustom"
  end
  
  def getHelpMessage
    return <<INFO_MESSAGE_TEXT
・判定　判定値+nLxFy±修正値>=目標値
　'L'、'F'は"criticaL"、"Fumble"の意（'C'が標準ダイスボットの機能で使用済みのため）。
　ダイス数n、クリティカル値x、ファンブル値yで判定。
　判定値、n、x、y、修正値、目標値は省略可能。また、Lx、Fyを省略することによりクリティカルなし、ファンブルなしが可（両方省略は不可）。
　デフォルト値はダイス数2、クリティカル値12、ファンブル値2。
※クリティカル、ファンブルの発生しない判定やダメージロールは、標準ダイスボットの利用を推奨。
例）
  2+LF+3>=12  2+ダイス2個の合計+3が12以上なら成功
  2+LF+3>12   2+ダイス2個の合計+3が12より大きいなら成功
  4+L10F  4+ダイス2個の合計、クリティカル値10
  F4-4  ダイス2個の合計-4、ファンブル値4、クリティカルが発生しない
  5F+7  ダイス5個の合計+7、クリティカルなし、ファンブルも実質発生しない
INFO_MESSAGE_TEXT
  end
  
  def help_message
    getHelpMessage
  end
  
  def rollDiceCommand(command)
    result = checkRoll(command)
    return result unless(result.empty?)
  end
  
  
  def checkRoll(string)
    dice_num = 2
    critical = 12
    fumble = 2
    base_str = mod_str = lg_str = target = nil
    is_no_critical = is_no_fumble = false
    
    case string
    when /\A([\d\+\-\(][\d\+\-\*\/\(\)]*[\+])?(\d+|\([\d\+\-\*\/\(\)]+\))?L(\d+|\([\d\+\-\*\/\(\)]+\))?F(\d+|\([\d\+\-\*\/\(\)]+\))?([\+\-][\d\+\-\(][\d\+\-\*\/\(\)]*)?(?:(\>=?)([\d\+\-\(][\d\+\-\*\/\(\)]*))?\z/i
        #/\A([\d\+\-\(][\d\+\-\*\/\(\)]*[\+])?(\d+|\([\d\+\-\*\/\(\)]+\))?D6?\((\d+|\([\d\+\-\*\/\(\)]+\))?\,(\d+|\([\d\+\-\*\/\(\)]+\))?\)([\+\-][\d\+\-\(][\d\+\-\*\/\(\)]*)?(?:(\>=?)([\d\+\-\(][\d\+\-\*\/\(\)]*))?\z/i
      base_str = $1 if $1
      dice_num = parren_killer($2).to_i if $2
      critical = parren_killer($3).to_i if $3
      fumble = parren_killer($4).to_i if $4
      mod_str = $5 if $5
      lg_str = $6 if $6
      target = parren_killer('(0' + $7 + ')').to_i if $7
    when /\A([\d\+\-\(][\d\+\-\*\/\(\)]*[\+])?(\d+|\([\d\+\-\*\/\(\)]+\))?L(\d+|\([\d\+\-\*\/\(\)]+\))?([\+\-][\d\+\-\(][\d\+\-\*\/\(\)]*)?(?:(\>=?)([\d\+\-\(][\d\+\-\*\/\(\)]*))?\z/i
      base_str = $1 if $1
      dice_num = parren_killer($2).to_i if $2
      critical = parren_killer($3).to_i if $3
      is_no_fumble = true
      mod_str = $4 if $4
      lg_str = $5 if $5
      target = parren_killer('(0' + $6 + ')').to_i if $6
    when /\A([\d\+\-\(][\d\+\-\*\/\(\)]*[\+])?(\d+|\([\d\+\-\*\/\(\)]+\))?F(\d+|\([\d\+\-\*\/\(\)]+\))?([\+\-][\d\+\-\(][\d\+\-\*\/\(\)]*)?(?:(\>=?)([\d\+\-\(][\d\+\-\*\/\(\)]*))?\z/i
      base_str = $1 if $1
      dice_num = parren_killer($2).to_i if $2
      is_no_critical = true
      fumble = parren_killer($3).to_i if $3
      mod_str = $4 if $4
      lg_str = $5 if $5
      target = parren_killer('(0' + $6 + ')').to_i if $6
    else
      return nil
    end

    base_str.gsub!(/\s+/, '') if base_str
    mod_str.gsub!(/\s+/, '') if mod_str
    
    base_value = parren_killer('(' + (base_str || '') + '0)').to_i 
    dice_result, dice_str = roll(dice_num, 6)
    dice_list = dice_str.split(/,/).collect {|i| i.to_i }
    mod_value = parren_killer('(0' + (mod_str || '') + ')').to_i 
    result_value = base_value + dice_result + mod_value
    result_str = "(#{base_str}#{dice_num}D6#{mod_str}#{lg_str}#{target}) → #{base_str}#{dice_result}[#{dice_list.join(',')}]#{mod_str}"
    
    if dice_result <= fumble && !is_no_fumble
      "#{result_str} → ダイス合計 #{fumble}以下 → ファンブル！"
    elsif dice_result >= critical && !is_no_critical
      "#{result_str} → ダイス合計 #{critical}以上 → クリティカル！"
    elsif !lg_str
      "#{result_str} → 達成値 #{result_value}"
    else
      "#{result_str}#{lg_str}#{target} → " +
        if lg_str == '>='
          "達成値 #{result_value}、目標値 #{target}"
        elsif lg_str == '>'
          target = target + 1
          "達成値 #{result_value}、目標値 #{target - 1}+1"
        else
          "その時、不思議なことが起こった！ #{string} → #{result_str}"
        end + " → #{result_value >= target ? '成功' : '失敗'}"
    end
  end
end
