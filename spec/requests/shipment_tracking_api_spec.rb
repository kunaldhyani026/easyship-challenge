require 'rails_helper'

RSpec.describe 'Shipment Tracking API', type: :request do
  describe 'GET /companies/:company_id/shipments/:id/tracking' do
    before do
      # creating test data
      company1 = create(:company, name: 'Example Inc', id: 1)
      shipment1 = create(:shipment, company: company1, id: 1, destination_country: 'UK', origin_country: 'IND', tracking_number: 'IND1234UK', slug: 'dhl', created_at: '2018-06-27 04:49:15')

      create(:shipment_item, shipment: shipment1, id: 1, description: 'iPhone', weight: 125)
      create(:shipment_item, shipment: shipment1, id: 2, description: 'iPhone', weight: 125)
      create(:shipment_item, shipment: shipment1, id: 3, description: 'Apple Watch', weight: 15)
      create(:shipment_item, shipment: shipment1, id: 4, description: 'iPhone', weight: 125)
      create(:shipment_item, shipment: shipment1, id: 5, description: 'Apple Watch', weight: 15)
      create(:shipment_item, shipment: shipment1, id: 6, description: 'Macbook', weight: 800)
    end

    context 'when the shipment exists and tracking information is available' do
      let(:succeeded_tracking_info) { JSON.parse(File.read(Rails.root.join('spec/fixtures/aftership/get_success_response.json'))).with_indifferent_access }

      before do
        # Stub the AftershipClient to return a valid tracking info response
        allow(AftershipClient).to receive(:get_tracking_info).and_return(succeeded_tracking_info)
      end

      it 'returns the tracking information' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/1/tracking', headers: headers

        # assert status is 200
        expect(response.status).to eq(200)

        # assert that expected body values are received
        body = response_body
        expect(body['status']).to eq('InTransit')
        expect(body['current_location']).to eq('Singapore Main Office, Singapore')
        expect(body['last_checkpoint_message']).to eq('Received at Operations Facility')
        expect(body['last_checkpoint_time']).to eq('Monday, 01 February 2016 at 1:00 PM')
      end
    end

    context 'when the shipment exists but tracking information is unavailable' do
      let(:failed_tracking_info) { JSON.parse(File.read(Rails.root.join('spec/fixtures/aftership/get_failure_response.json'))).with_indifferent_access }

      before do
        # Stub the AftershipClient to return an invalid tracking info response
        allow(AftershipClient).to receive(:get_tracking_info).and_return(failed_tracking_info)
      end

      it 'returns a not found response' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/1/tracking', headers: headers

        # assert status is 404
        expect(response.status).to eq(404)

        # asserting that response body have error details
        body = response_body
        expect(body.has_key?('error')).to eq(true)
        expect(body['error']['code']).to eq('resource_not_found')
        expect(body['error']['message']).to eq('Tracking does not exist.')
        expect(body['error']['type']).to eq('invalid_request_error')
      end
    end

    context 'when the shipment does not exist' do
      it 'returns a not found response' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/2/tracking', headers: headers

        # assert status is 404
        expect(response.status).to eq(404)

        # asserting that response body have error details
        body = response_body
        expect(body.has_key?('error')).to eq(true)
        expect(body['error']['code']).to eq('resource_not_found')
        expect(body['error']['message']).to eq("Couldn't find Shipment with 'id'=2 and 'company_id'=1")
        expect(body['error']['type']).to eq('invalid_request_error')
      end
    end

    context 'when API params are invalid' do
      it 'returns a bad request response when shipment id is invalid' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/hello/tracking', headers: headers

        # assert status is 400
        expect(response.status).to eq(400)

        # asserting that response body have error details
        body = response_body
        expect(body.has_key?('error')).to eq(true)
        expect(body['error']['code']).to eq('invalid_request')
        expect(body['error']['message']).to eq('The request param are not valid.')
        expect(body['error']['type']).to eq('invalid_request_error')
      end

      it 'returns a bad request response when company id is invalid' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/12ac/shipments/1/tracking', headers: headers

        # assert status is 400
        expect(response.status).to eq(400)

        # asserting that response body have error details
        body = response_body
        expect(body.has_key?('error')).to eq(true)
        expect(body['error']['code']).to eq('invalid_request')
        expect(body['error']['message']).to eq('The request param are not valid.')
        expect(body['error']['type']).to eq('invalid_request_error')
      end
    end

    context 'when Aftership API key is invalid' do
      it 'returns a 401 Unauthorized response' do
        # Trigger API call - This actually calls Aftership endpoint with a bad as-api-key, which leads to 401 error
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/1/tracking', headers: headers

        # assert status is 401
        expect(response.status).to eq(401)

        # asserting that response body have error details
        body = response_body
        expect(body.has_key?('error')).to eq(true)
        expect(body['error']['code']).to eq('api_error')
        expect(body['error']['message']).to eq('The API key is invalid.')
        expect(body['error']['type']).to eq('Unauthorized')
      end
    end

    context 'when encountering a JSON::ParserError' do
      before do
        allow(AftershipClient).to receive(:parse_http_response).and_raise(JSON::ParserError)
      end

      it 'returns a specific 500 api_error response' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/1/tracking', headers: headers

        # assert status is 500
        expect(response.status).to eq(500)

        # asserting that response body have error details
        body = response_body
        expect(body.has_key?('error')).to eq(true)
        expect(body['error']['code']).to eq('api_error')
        expect(body['error']['message']).to eq('Failed to parse response body as JSON')
        expect(body['error']['type']).to eq('api_error')
      end
    end

    context 'when encountering a 5xx server error response from Net::Http' do
      it 'returns a specific 500 api_error response when HTTPServerError response is received' do
        allow(AftershipClient).to receive(:trigger_http_request).and_return(Net::HTTPServerError.new(1, 500, 'Testing - HTTPServerError'))

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/1/tracking', headers: headers

        # assert status is 500
        expect(response.status).to eq(500)

        # asserting that response body have error details
        body = response_body
        expect(body.has_key?('error')).to eq(true)
        expect(body['error']['code']).to eq('api_error')
        expect(body['error']['message']).to eq('Internal Server Error')
        expect(body['error']['type']).to eq('http_network_error')
      end

      it 'returns a specific 500 api_error response when HTTPBadGateway response is received' do
        allow(AftershipClient).to receive(:trigger_http_request).and_return(Net::HTTPBadGateway.new(1, 502, 'Testing - HTTPBadGateway'))

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/1/tracking', headers: headers

        # assert status is 500
        expect(response.status).to eq(500)

        # asserting that response body have error details
        body = response_body
        expect(body.has_key?('error')).to eq(true)
        expect(body['error']['code']).to eq('api_error')
        expect(body['error']['message']).to eq('Internal Server Error')
        expect(body['error']['type']).to eq('http_network_error')
      end

      it 'returns a specific 500 api_error response when HTTPGatewayTimeout response is received' do
        allow(AftershipClient).to receive(:trigger_http_request).and_return(Net::HTTPGatewayTimeout.new(1, 504, 'Testing - HTTPGatewayTimeout'))

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/1/tracking', headers: headers

        # assert status is 500
        expect(response.status).to eq(500)

        # asserting that response body have error details
        body = response_body
        expect(body.has_key?('error')).to eq(true)
        expect(body['error']['code']).to eq('api_error')
        expect(body['error']['message']).to eq('Internal Server Error')
        expect(body['error']['type']).to eq('http_network_error')
      end

      it 'returns a specific 500 api_error response when HTTPInternalServerError response is received' do
        allow(AftershipClient).to receive(:trigger_http_request).and_return(Net::HTTPInternalServerError.new(1, 500, 'Testing - HTTPInternalServerError'))

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/1/tracking', headers: headers

        # assert status is 500
        expect(response.status).to eq(500)

        # asserting that response body have error details
        body = response_body
        expect(body.has_key?('error')).to eq(true)
        expect(body['error']['code']).to eq('api_error')
        expect(body['error']['message']).to eq('Internal Server Error')
        expect(body['error']['type']).to eq('http_network_error')
      end
    end
  end

  def response_body
    JSON.parse(response.body)
  end
end
