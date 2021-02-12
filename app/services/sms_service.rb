require 'redis'
class SmsService
  REDIS = Redis.new(host: "localhost")
  # Max number of requests from the same from number
  MAX_REQUEST_COUNT = 50
  # Request count resets after 24 hours
  REQUEST_TIMEOUT = 24*3600

  def self.process_inbound_sms(account_id:, from:, to:, message:)
    begin
      to_phone_number = PhoneNumber.find_by(number: to)
      error_message = nil
      if !to_phone_number || account_id != to_phone_number.account_id
        error_message = "to parameter not found"
        return {message: "", error: error_message}, 422
      end
      if message.strip == "STOP"
        Rails.cache.write("stop-[#{from},#{to}]", true, expires_in: 30.seconds)
      end
      return {message: "inbound sms ok", error: ""}
    rescue Exception => e
      return {message: "", error: "unknown failure"}
    end
  end

  def self.process_outbound_sms(account_id:, from:, to:, message:)
    begin
      to_phone_number = PhoneNumber.find_by(number: from)
      error_message = nil
      if !to_phone_number || account_id != to_phone_number.account_id
        error_message = "from parameter not found"
        return {message: "", error: error_message}, 422
      end
      if Rails.cache.read("stop-[#{from},#{to}]")
        return {message: "", error: "sms from #{from} to #{to} blocked by STOP request"}, 422
      end
      redis_counter_key = "counter-[#{from},#{to}]"
      request_count = REDIS.get(redis_counter_key)
      if request_count && request_count.to_i >= MAX_REQUEST_COUNT
        return {message: "", error: "limit reached for from #{from}"}, 429
      end
      unless REDIS.get(redis_counter_key)
        REDIS.set(redis_counter_key, 1, ex: REQUEST_TIMEOUT)
      else
        REDIS.incr(redis_counter_key)
      end
      return {message: "outbound sms ok, counter: #{REDIS.get(redis_counter_key)}", error: ""}
    rescue Exception => e
      return {message: "", error: "unknown failure"}
    end
  end
end