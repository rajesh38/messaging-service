class SmsController < ApplicationController
  before_action :validate_http_method, only: [:inbound, :outbound]
  before_action :validate_inbound_params, only: :inbound
  before_action :validate_outbound_params, only: :inbound

  ATTR_VALIDATIONS = {
    inbound: {
      from: {
        min_length: 6,
        max_length: 16,
        required: true
      },
      to: {
        min_length: 6,
        max_length: 16,
        required: true
      },
      text: {
        min_length: 1,
        max_length: 120,
        required: true
      }
    },
    outbound: {
      from: {
        min_length: 6,
        max_length: 16,
        required: true
      },
      to: {
        min_length: 6,
        max_length: 16,
        required: true
      },
      text: {
        min_length: 1,
        max_length: 120,
        required: true
      }
    },
  }

  def inbound
    data, status = SmsService.process_inbound_sms(
      account_id: @account.id,
      from: params[:from],
      to: params[:to],
      message: params[:text])
    render json: data, status: (data[:error].present? ? 500 : 200)
  end

  def outbound
    data, status = SmsService.process_outbound_sms(
      account_id: @account.id,
      from: params[:from],
      to: params[:to],
      message: params[:text])
    render json: data, status: (status ? status : (data[:error].present? ? 500 : 200))
  end

  private

  def validate_http_method
    render status: 405 if request.method != "POST"
  end

  def validate_inbound_params
    error_message = validate_method_params(:inbound)
    render json: {message: "", error: error_message}, status: 406 if error_message
  end

  def validate_outbound_params
    error_message = validate_method_params(:outbound)
    render json: {message: "", error: error_message}, status: 422 if error_message
  end

  def validate_method_params(method_name)
    required_params = ATTR_VALIDATIONS.keys.select{|k| ATTR_VALIDATIONS[k][:required]}
    error_message = nil
    required_params.each do |param|
      if request[param].blank?
        error_messages = "#{param.to_s} is missing"
        break
      end
    end
    ATTR_VALIDATIONS.keys.each do |key|
      error_message = attr_other_validation_error(key)
      return error_message if error_message
    end
    error_message
  end

  def attr_other_validation_error(attr_name)
    error_message = nil
    if attr_name.in?(ATTR_VALIDATIONS.keys)
      min_length = ATTR_VALIDATIONS[attr_name][:min_length]
      max_length = ATTR_VALIDATIONS[attr_name][:max_length]
      if min_length && params[:attr_name].length < min_length
        error_message = "#{attr_name} is invalid"
        return error_message
      end
      if max_length && params[:attr_name].length > max_length
        error_message = "#{attr_name} is invalid"
        return error_message
      end      
    end 
  end
end