#encoding: utf-8
require 'xmlsimple'
class Voyage
  def self.response_xml message
    body_obj = { "ToUserName" => message[:from],
                 "FromUserName" => message[:to],
                 "CreateTime" => DateTime.now.to_i.to_s,
                 "MsgType" => "text",
                 "Content" => "hello" + message[:content],
                 "MsgId" => "1234567890123459"
    }
    body_obj.to_xml root: "xml"
  end

  def self.parse xml
    parsed_xml = XmlSimple.xml_in(xml, "ForceArray" => false)
    if parsed_xml["MsgType"] == "event"
      obj = {
          to: parsed_xml["ToUserName"],
          from: parsed_xml["FromUserName"],
          event: parsed_xml["Event"].strip,
          event_key: parsed_xml["EventKey"],
          type: parsed_xml["MsgType"],
          created_at: parsed_xml["CreateTime"]
      }
    else
      obj = {
          to: parsed_xml["ToUserName"],
          from: parsed_xml["FromUserName"],
          content: parsed_xml["Content"].strip,
          type: parsed_xml["MsgType"],
          created_at: parsed_xml["CreateTime"]
      }
    end
    obj
  end
end
