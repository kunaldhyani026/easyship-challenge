require 'rails_helper'

RSpec.describe 'Search Shipment by number of items API', type: :request do
  describe 'POST /companies/:company_id/shipments/search' do
    before do
      # creating test data
      company1 = create(:company, name: 'Example Inc', id: 1)
      _shipment1 = create(:shipment, company: company1, id: 1, destination_country: 'UK', origin_country: 'IND', tracking_number: 'IND1234UK', slug: 'dhl', created_at: '2018-06-27 04:49:15')
      shipment2 = create(:shipment, company: company1, id: 2, destination_country: 'NED', origin_country: 'ENG', tracking_number: 'ENG8765NED', slug: 'usps', created_at: '2020-12-20 22:35:20')
      shipment3 = create(:shipment, company: company1, id: 3, destination_country: 'AUS', origin_country: 'NZ', tracking_number: 'NZ9876AUS', slug: 'ups', created_at: '2022-08-22 01:30:20')
      shipment4 = create(:shipment, company: company1, id: 4, destination_country: 'USA', origin_country: 'WI', tracking_number: 'WI4321USA', slug: 'ups', created_at: '2022-10-15 07:22:20')

      create(:shipment_item, shipment: shipment2, id: 1, description: 'iPhone', weight: 125)
      create(:shipment_item, shipment: shipment2, id: 2, description: 'iPhone', weight: 125)
      create(:shipment_item, shipment: shipment2, id: 3, description: 'Apple Watch', weight: 15)
      create(:shipment_item, shipment: shipment2, id: 4, description: 'iPhone', weight: 125)
      create(:shipment_item, shipment: shipment2, id: 5, description: 'Apple Watch', weight: 15)
      create(:shipment_item, shipment: shipment2, id: 6, description: 'Macbook', weight: 800)

      create(:shipment_item, shipment: shipment3, id: 7, description: 'Airpods', weight: 50)
      create(:shipment_item, shipment: shipment3, id: 8, description: 'iTag', weight: 80)
      create(:shipment_item, shipment: shipment3, id: 9, description: 'Airpods', weight: 50)
      create(:shipment_item, shipment: shipment3, id: 10, description: 'iTag', weight: 80)
      create(:shipment_item, shipment: shipment3, id: 11, description: 'iTag', weight: 80)
      create(:shipment_item, shipment: shipment3, id: 12, description: 'iTag', weight: 80)

      create(:shipment_item, shipment: shipment4, id: 13, description: 'iPad', weight: 1280)
    end

    context 'when shipments exists' do
      it 'returns success response for shipments with zero shipment_items_size = 0' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => 0 }
        post '/companies/1/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 200
        expect(response.status).to eq(200)

        # asserting that response body is as expected
        body = response_body
        expect(body).to eq({
                             'shipments' => [
                               {
                                 'id' => 1,
                                 'company_id' => 1,
                                 'destination_country' => 'UK',
                                 'origin_country' => 'IND',
                                 'tracking_number' => 'IND1234UK',
                                 'slug' => 'dhl',
                                 'created_at' => '2018 June 27 at 4:49 AM (Wednesday)',
                                 'items' => []
                               }
                             ]
                           })
      end

      it 'returns success response for shipments with shipment_items_size = 1' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => 1 }
        post '/companies/1/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 200
        expect(response.status).to eq(200)

        # asserting that response body is as expected
        body = response_body
        expect(body).to eq({
                             'shipments' => [
                               {
                                 'id' => 4,
                                 'company_id' => 1,
                                 'destination_country' => 'USA',
                                 'origin_country' => 'WI',
                                 'tracking_number' => 'WI4321USA',
                                 'slug' => 'ups',
                                 'created_at' => '2022 October 15 at 7:22 AM (Saturday)',
                                 'items' => [
                                   {'description' => 'iPad', 'count' => 1}
                                 ]
                               }
                             ]
                           })
      end

      it 'returns success response for shipments with shipment_items_size more than one' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => 6 }
        post '/companies/1/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 200
        expect(response.status).to eq(200)

        # asserting that response body is as expected
        body = response_body
        expect(body).to eq({
                             'shipments' => [
                               {
                                 'id' => 2,
                                 'company_id' => 1,
                                 'destination_country' => 'NED',
                                 'origin_country' => 'ENG',
                                 'tracking_number' => 'ENG8765NED',
                                 'slug' => 'usps',
                                 'created_at' => '2020 December 20 at 10:35 PM (Sunday)',
                                 'items' => [
                                   {'description' => 'Macbook', 'count' => 1},
                                   {'description' => 'Apple Watch', 'count' => 2},
                                   {'description' => 'iPhone', 'count' => 3}
                                 ]
                               },
                               {
                                 'id' => 3,
                                 'company_id' => 1,
                                 'destination_country' => 'AUS',
                                 'origin_country' => 'NZ',
                                 'tracking_number' => 'NZ9876AUS',
                                 'slug' => 'ups',
                                 'created_at' => '2022 August 22 at 1:30 AM (Monday)',
                                 'items' => [
                                   {'description' => 'Airpods', 'count' => 2},
                                   {'description' => 'iTag', 'count' => 4}
                                 ]
                               }
                             ]
                           })
      end
    end

    context 'when shipments does not exists' do
      it 'returns success response with empty shipments array when there are no shipments for specified company_id' do
        # here in this test case, there are no shipments of company_id = 4
        shipment_objects = Shipment.where(company_id: 4)
        expect(shipment_objects.length).to eq(0)

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => 6 }
        post '/companies/4/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 200
        expect(response.status).to eq(200)

        # asserting that response body is as expected
        body = response_body
        expect(body).to eq({
                             'shipments' => []
                           })
      end

      it 'returns success response with empty shipments array when there are no shipments for specified shipment_items_size' do
        # here in this test case, there are shipments of company_id = 1, but not of specified items size = 20
        shipment_objects = Shipment.where(company_id: 1)
        expect(shipment_objects.length).to eq(4)

        shipments_of_specified_items_size = Shipment.where(shipment_items_count: 20)
        expect(shipments_of_specified_items_size.length).to eq(0)

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => 20 }
        post '/companies/1/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 200
        expect(response.status).to eq(200)

        # asserting that response body is as expected
        body = response_body
        expect(body).to eq({
                             'shipments' => []
                           })
      end
    end

    context 'when params are not valid' do
      it 'returns a bad request response when shipment_items_size is invalid : integer string with spaces' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => ' 6' }
        post '/companies/1/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 400
        expect(response.status).to eq(400)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'invalid_request',
                               'message' => 'The request param are not valid.',
                               'type' => 'invalid_request_error'
                             }
                           })
      end

      it 'returns a bad request response when shipment_items_size is invalid : string with only spaces' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => '  ' }
        post '/companies/1/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 400
        expect(response.status).to eq(400)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'invalid_request',
                               'message' => 'The request param are not valid.',
                               'type' => 'invalid_request_error'
                             }
                           })
      end

      it 'returns a bad request response when shipment_items_size invalid : integer string with leading zeroes' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => '06' }
        post '/companies/1/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 400
        expect(response.status).to eq(400)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'invalid_request',
                               'message' => 'The request param are not valid.',
                               'type' => 'invalid_request_error'
                             }
                           })
      end

      it 'returns a bad request response when shipment_items_size invalid : negative integer string' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => '-6' }
        post '/companies/1/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 400
        expect(response.status).to eq(400)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'invalid_request',
                               'message' => 'The request param are not valid.',
                               'type' => 'invalid_request_error'
                             }
                           })
      end

      it 'returns a bad request response when shipment_items_size invalid : negative integer' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => -2 }
        post '/companies/1/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 400
        expect(response.status).to eq(400)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'invalid_request',
                               'message' => 'The request param are not valid.',
                               'type' => 'invalid_request_error'
                             }
                           })
      end

      it 'returns a bad request response when company id invalid : integer string with spaces' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => 6 }
        post '/companies/%204/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 400
        expect(response.status).to eq(400)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'invalid_request',
                               'message' => 'The request param are not valid.',
                               'type' => 'invalid_request_error'
                             }
                           })
      end

      it 'returns a bad request response when company id is invalid : string with only spaces' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => 6 }
        post '/companies/%20%20/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 400
        expect(response.status).to eq(400)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'invalid_request',
                               'message' => 'The request param are not valid.',
                               'type' => 'invalid_request_error'
                             }
                           })
      end

      it 'returns a bad request response when company id invalid : string with spaces' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'shipment_items_size' => 6 }
        post '/companies/%20%20/shipments/search', params: payload.to_json, headers: headers

        # asserting that response status is 400
        expect(response.status).to eq(400)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'invalid_request',
                               'message' => 'The request param are not valid.',
                               'type' => 'invalid_request_error'
                             }
                           })
      end
    end
  end

  def response_body
    JSON.parse(response.body)
  end
end


