class SmsController < ApplicationController
  before_action :validate_http_method, only: [:inbound, :outbound]
  before_action :validate_inbound_params, only: :inbound
  before_action :validate_outbound_params, only: :outbound

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
    method_attr_validations = ATTR_VALIDATIONS[method_name]
    required_params = method_attr_validations.keys.select{|k| method_attr_validations[k][:required]}
    error_message = nil
    required_params.each do |param_name|
      return "#{param_name.to_s} is missing" if params[param_name].blank?
    end
    method_attr_validations.keys.each do |key|
      error_message = attr_other_validation_error(method_name, key)
      return error_message if error_message
    end
    error_message
  end

  def attr_other_validation_error(method_name, attr_name)
    error_message = nil
    method_attr_validations = ATTR_VALIDATIONS[method_name]
    if attr_name.in?(method_attr_validations.keys)
      min_length = method_attr_validations[attr_name][:min_length]
      max_length = method_attr_validations[attr_name][:max_length]
      if min_length && params[attr_name].length < min_length
        error_message = "#{attr_name} is invalid"
        return error_message
      end
      if max_length && params[attr_name].length > max_length
        error_message = "#{attr_name} is invalid"
        return error_message
      end      
    end 
  end
end