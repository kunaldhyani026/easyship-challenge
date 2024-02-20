require 'uri'
require 'net/http'
require 'openssl'

# AFTERSHIP_API_KEY is stored in environment variables for security.
# Considering that Easyship purchased Aftership licenced API KEY to be used across Easyship Application to access Aftership APIs
# For production grade apps, secrets manager like AWS Secrets Manager can be used.
class AftershipClient
  BASE_URL = 'https://api.aftership.com/tracking/2024-01'.freeze
  API_KEY = ENV['AFTERSHIP_API_KEY']

  def self.get_tracking_info(tracking_number)
    url = URI("#{BASE_URL}/trackings/#{tracking_number}?lang=en")
    http_get(url)
  end

  # For Task 3, last_checkpoint info API is more helpful as this API gives all info as expected for response of task3.
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

    response = http.request(request)
    JSON.parse(response.read_body).with_indifferent_access
  end

end