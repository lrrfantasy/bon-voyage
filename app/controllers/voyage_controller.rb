require 'xmlsimple'
class VoyageController < ApplicationController
  layout false

  before_filter :validate_token

  def response_xml
    message = Voyage.parse request.body
    render :xml => Voyage.response_xml(message)
  end

  def validate_echostr
    render :text => params[:echostr]
  end

  def validate_token
    array = [Rails.configuration.token, params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end
end
