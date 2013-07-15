#encoding: utf-8
require 'xmlsimple'

class Voyage
  REGISTER = '注册'
  LEARN_SKILL = '学习技能'
  GO_OUT = '出城'

  def self.response_xml message
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

  def self.get_content user_id, content, start_time
    message = ''
    user = safe_find_user(user_id)

    if user.name.nil? && !user.at?(REGISTER)
      message += '你是新来的？取个名字吧。'
      user.save_value :sys_stat, REGISTER
      return message
    end

    if user.at? REGISTER
      user.new_user content
    elsif user.at? LEARN_SKILL
      message += user.learn_skill content
    elsif user.at? GO_OUT
      message += user.go_to content, start_time
    elsif user.at? '行动'
      message += user.check_action start_time
      return message
    end

    if content == '状态'
      message += user.get_stat
    elsif content == '技能'
      message += "拥有的技能：\n"
      personal_skills = user.get_skills
      personal_skills.each { |skill|
        message += "#{skill.name}：Lv.#{skill.level} Exp:#{skill.exp}/#{skill.level**2*100}\n"
      }
    elsif !(match = (content.match /^学习技能( .+)?$/)).nil?
      if match[1].nil?
        message += "请选择你要学习的技能\n"
        Skill.all.each { |skill|
          message += "#{skill.name}\n"
        }
        user.save_value :sys_stat, LEARN_SKILL
      else
        message += user.learn_skill match[1].strip
      end
      #TODO this is a GM function
    elsif !(match = (content.match /^技能经验 (.+) (.+)/)).nil?
      skill_name = match[1]
      exp = match[2]
      message += user.exp_skill skill_name, exp
    elsif !(match = (content.match /^出城( .+)?$/)).nil?
      if match[1].nil?
        message += "请选择你要去的城市\n"
        City.all.reject { |city| city.name == user.position }.each { |city|
          message += "#{city.name}\n"
        }
        user.save_value :sys_stat, GO_OUT
      else
        message += user.go_to match[1].strip, start_time
      end
    end

    if message == ''
      message = "你好，#{user.name}"
    end
    message
  end

  def self.safe_find_user user_id
    user = User.where(:user_id => user_id).first
    if user.nil?
      user = User.create(user_id: user_id, sys_stat: '')
      PersonalAction.create(user_id: user_id)
    end
    user
  end

  def self.parse xml
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

  def self.safe_equal? variable, value
    variable.nil? ? false : variable == value
  end
end
