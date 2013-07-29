#encoding: utf-8
require 'xmlsimple'

class Voyage

  def self.get_content(user_wechat_id, content, start_time)
    message = ''
    user = safe_find_user(user_wechat_id)

    if user.name.nil? && !user.at?(SysStat.register)
      message += '你是新来的？取个名字吧。'
      user.save_value :sys_stat, SysStat.register
      return message
    end

    if user.at? SysStat.register
      user.new_user content
    elsif user.at? SysStat.learn_skill
      message += user.learn_skill content
    elsif user.at? SysStat.intro_skill
      message += user.intro_skill content
    elsif user.at? SysStat.go_out
      message += user.go_to content, start_time
    elsif user.at? SysStat.market
      if (match = (content.match /^买 (.+) (.+)/)).present?
        message += user.buy_product match[1], match[2]
      elsif !(match = (content.match /^卖 (.+) (.+)/)).nil?
        message += user.sell_product match[1], match[2]
      elsif content == '全部卖出'
        message += user.sell_all
      elsif content == '返回'
        user.clear_sys_stat
      end
    elsif user.at? SysStat.action
      #TODO GM function
      if content == '秒到'
        user.personal_action.last_time = '0'
        user.personal_action.save
      end
      wrap = user.check_action start_time
      message += wrap[0]
      return message if !wrap[1]
    end

    if content == '状态'
      message += user.get_stat
    elsif content == '技能'
      message += "拥有的技能：\n"
      user.personal_skills.each { |skill|
        message += "#{skill.name}：Lv.#{skill.level} Exp:#{skill.exp}/#{skill.level**2*100}\n"
      }
    elsif !(match = (content.match /^学习技能( .+)?$/)).nil?
      if match[1].nil?
        message += "请选择你要学习的技能\n"
        Skill.all.each { |skill|
          message += "#{skill.name}\n"
        }
        user.save_value :sys_stat, SysStat.intro_skill
      else
        message += user.learn_skill match[1].strip
      end
      #TODO this is a GM function
    elsif (match = (content.match /^技能经验 (.+) (.+)/)).present?
      skill_name = match[1]
      exp = match[2]
      message += user.exp_skill skill_name, exp
    elsif (match = (content.match /^出城( .+)?$/)).present?
      if match[1].nil?
        message += "请选择你要去的城市\n"
        City.all.reject { |city|
          city == user.city
        }.each { |city|
          message += "#{city.name}\n"
        }
        user.save_value :sys_stat, SysStat.go_out
      else
        message += user.go_to match[1].strip, start_time
      end
    elsif content == '市场'
      message += user.market_info
    end

    if message == ''
      message = "你好，#{user.name}"
    end
    message
  end

  def self.safe_find_user(user_wechat_id)
    user = User.where(:user_wechat_id => user_wechat_id).first
    if user.nil?
      user = User.create(user_wechat_id: user_wechat_id, sys_stat: '')
      user.build_personal_action
      user.save
    end
    user
  end

  def self.response_xml(message)
    content = get_content message[:from], message[:content], message[:created_at]
    body_obj = {"ToUserName" => message[:from],
                "FromUserName" => message[:to],
                "CreateTime" => DateTime.now.to_i.to_s,
                "MsgType" => 'text',
                "Content" => content,
                "MsgId" => '1234567890123459'
    }
    body_obj.to_xml root: 'xml'
  end

  def self.parse(xml)
    parsed_xml = XmlSimple.xml_in(xml, "ForceArray" => false)
    if parsed_xml["MsgType"] == "event"
      obj = {
          to: parsed_xml['ToUserName'],
          from: parsed_xml['FromUserName'],
          event: parsed_xml['Event'].strip,
          event_key: parsed_xml['EventKey'],
          type: parsed_xml['MsgType'],
          created_at: parsed_xml['CreateTime']
      }
    else
      obj = {
          to: parsed_xml['ToUserName'],
          from: parsed_xml['FromUserName'],
          content: parsed_xml['Content'].strip,
          type: parsed_xml['MsgType'],
          created_at: parsed_xml['CreateTime']
      }
    end
    obj
  end
end
