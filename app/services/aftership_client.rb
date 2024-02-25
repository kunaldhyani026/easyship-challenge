require 'uri'
require 'net/http'
require 'openssl'

# AFTERSHIP_API_KEY is stored in environment variables for security.
# Considering that Easyship purchased Aftership licenced API KEY to be used across Easyship Application to access Aftership APIs
# For production systems, secrets manager like AWS Secrets Manager can be used.
class AftershipClient
  BASE_URL = 'https://api.aftership.com/tracking/2024-01'.freeze
  API_KEY = ENV['AFTERSHIP_API_KEY']

  def self.get_tracking_info(tracking_number)
    url = URI("#{BASE_URL}/trackings/#{tracking_number}?lang=en")
    http_get(url)
  end

  # For Task 3, Below last_checkpoint info API is more helpful as this API gives all info as expected for response of task3.
  # However, as available fake responses are of get_tracking_info, we will be using that in our task3.
  def self.get_last_checkpoint_info(tracking_number)
    url = URI("#{BASE_URL}/last_checkpoint/#{tracking_number}")
    http_get(url)
  end

  private_class_method def self.http_get(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request['Content-Type'] = 'application/json'
    request['as-api-key'] = API_KEY

    begin
      parse_http_response(trigger_http_request(http, request))
    rescue JSON::ParserError
      { meta: { code: 500, message: 'Failed to parse response body as JSON', type: 'api_error'} }
    end
  end

  private_class_method def self.trigger_http_request(http, request)
    http.request(request)
  end

  # This methods logs 5xx error (if any) occurred on Aftership's server and returns 500 to Easyship's user stating Internal Server Error
  # Otherwise parses and returns response body
  private_class_method def self.parse_http_response(response)
    if server_error?(response)
      Rails.logger.error("<<<<< Server Error occurred on Aftership API : #{response.message} >>>>>")
      return { meta: { code: 500, message: 'Internal Server Error', type: 'http_network_error' } }
    end

    JSON.parse(response.read_body).with_indifferent_access
  end

  private_class_method def self.server_error?(response)
    status_code = response.code.to_i
    status_code >= 500 && status_code < 600
  end

end