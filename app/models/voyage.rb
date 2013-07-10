#encoding: utf-8
require 'xmlsimple'

class Voyage
  REGISTER = '注册'
  LEARN_SKILL = '学习技能'

  def self.response_xml message
    content = get_content message[:from], message[:content]
    body_obj = {"ToUserName" => message[:from],
                "FromUserName" => message[:to],
                "CreateTime" => DateTime.now.to_i.to_s,
                "MsgType" => 'text',
                "Content" => content,
                "MsgId" => '1234567890123459'
    }
    body_obj.to_xml root: 'xml'
  end

  def self.get_content user_id, content
    message = ''
    user = safe_find_user(user_id)

    if user.name.nil? && !user.at?(REGISTER)
      message += '你是新来的？取个名字吧。'
      user.save_value :position, REGISTER
      return message
    end

    if user.at? REGISTER
      user.new_user content
    elsif user.at? LEARN_SKILL
      message += (user.learn_skill? content) ? "你成功学会了技能：#{content}" : "学习技能失败\n技能不存在或者你已经学会此技能"
    end

    if content == '状态'
      message = "姓名：#{user.name}\n" +
          "等级：#{user.level.to_s}"
    elsif content == '技能'
      message += "拥有的技能：\n"
      personal_skills = user.get_skills
      personal_skills.each { |skill|
        message += "#{skill.name}：Lv#{skill.level}\n"
      }
    elsif content == '学习技能'
      message += "请选择你要学习的技能\n"
      Skill.all.each { |skill|
        message += "#{skill.name}\n"
      }
      user.save_value :position, LEARN_SKILL
    end

    if message == ''
      message = "你好，#{user.name}"
    end
    message
  end

  def self.safe_find_user user_id
    user = User.where(:user_id => user_id).first
    user = User.create(user_id: user_id, position: '') if user.nil?
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
