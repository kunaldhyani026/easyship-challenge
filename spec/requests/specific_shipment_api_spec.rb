require 'rails_helper'

RSpec.describe "Specific Shipment API", type: :request do
  describe 'GET /companies/:company_id/shipments/:id' do
    before do
      # creating test data
      company1 = create(:company, name: 'Example Inc', id: 1)
      _shipment1 = create(:shipment, company: company1, id: 1, destination_country: 'UK', origin_country: 'IND', tracking_number: 'IND1234UK', slug: 'dhl', created_at: '2018-06-27 04:49:15')
      shipment2 = create(:shipment, company: company1, id: 2, destination_country: 'NED', origin_country: 'ENG', tracking_number: 'ENG8765NED', slug: 'usps', created_at: '2020-12-20 22:35:20')

      create(:shipment_item, shipment: shipment2, id: 1, description: 'iPhone', weight: 125)
      create(:shipment_item, shipment: shipment2, id: 2, description: 'iPhone', weight: 125)
      create(:shipment_item, shipment: shipment2, id: 3, description: 'Apple Watch', weight: 15)
      create(:shipment_item, shipment: shipment2, id: 4, description: 'iPhone', weight: 125)
      create(:shipment_item, shipment: shipment2, id: 5, description: 'Apple Watch', weight: 15)
      create(:shipment_item, shipment: shipment2, id: 6, description: 'Macbook', weight: 800)
    end

    context 'when shipment exists' do
      it 'returns a success response with empty array for items when shipment have no items' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/1', headers: headers

        # assert status is 200
        expect(response.status).to eq(200)

        # assert that expected body values are received
        body = response_body
        expect(body).to eq({
                             'shipment' => {
                               'company_id' => 1,
                               'destination_country' => 'UK',
                               'origin_country' => 'IND',
                               'tracking_number' => 'IND1234UK',
                               'slug' => 'dhl',
                               'created_at' => '2018 June 27 at 4:49 AM (Wednesday)',
                               'items' => []
                             }
                           })
      end

      it 'returns a success response with items array having description and count of shipment items' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/2', headers: headers

        # assert status is 200
        expect(response.status).to eq(200)

        # assert that expected body values are received
        body = response_body
        expect(body).to eq({
                             'shipment' => {
                               'company_id' => 1,
                               'destination_country' => 'NED',
                               'origin_country' => 'ENG',
                               'tracking_number' => 'ENG8765NED',
                               'slug' => 'usps',
                               'created_at' => '2020 December 20 at 10:35 PM (Sunday)',
                               'items' => [
                                 { 'description' => 'Macbook', 'count' => 1 },
                                 { 'description' => 'Apple Watch', 'count' => 2 },
                                 { 'description' => 'iPhone', 'count' => 3 }
                               ]
                             }
                           })
      end
    end

    context 'when shipment does not exist' do
      it 'returns a not found response when a shipment with specified company_id is not present' do
        # here in this test case, we do have a shipment with id = 1, but the specified company_id = 4 is not correct.

        # before API call asserting that shipment with id = 1 exists however it's company_id is not 4.
        shipment_object = Shipment.find(1)
        expect(shipment_object.company_id).not_to eq(4)

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/4/shipments/1', headers: headers

        # asserting that response status is 404
        expect(response.status).to eq(404)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'resource_not_found',
                               'message' => "Couldn't find Shipment with 'id'=1 and 'company_id'=4",
                               'type' => 'invalid_request_error'
                             }
                           })
      end

      it 'returns a not found response when a shipment with specified id is not present' do
        # here in this test case, we do have a company_id = 1, but the specified shipment with id = 5 is not correct.

        # before API call asserting that company_id = 1 exists however shipment with id = 5 is not there.
        company_object = Company.find(1)
        expect(company_object.id).to eq(1)
        expect(company_object.name).to eq('Example Inc')
        expect { Shipment.find(5) }.to raise_error(ActiveRecord::RecordNotFound)

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/1/shipments/5', headers: headers

        # asserting that response status is 404
        expect(response.status).to eq(404)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'resource_not_found',
                               'message' => "Couldn't find Shipment with 'id'=5 and 'company_id'=1",
                               'type' => 'invalid_request_error'
                             }
                           })
      end

      it 'returns a not found response when a shipment with specified id and company_id is not present' do
        # here in this test case, both company_id = 4 and shipment with id = 5 is not correct.

        # before API call asserting that company_id = 4 and shipment with id = 5 is not there.
        expect { Company.find(4) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { Shipment.find(5) }.to raise_error(ActiveRecord::RecordNotFound)

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/4/shipments/5', headers: headers

        # asserting that response status is 404
        expect(response.status).to eq(404)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'resource_not_found',
                               'message' => "Couldn't find Shipment with 'id'=5 and 'company_id'=4",
                               'type' => 'invalid_request_error'
                             }
                           })
      end
    end

    context 'when path params are not valid' do
      it 'returns a bad request response when shipment id invalid : empty string' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/4/shipments/%20', headers: headers

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
        get '/companies/%20%20/shipments/1', headers: headers

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

      it 'returns a bad request response when both id and company id is invalid' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/%20%20/shipments/%20', headers: headers

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
        get '/companies/%204/shipments/1', headers: headers

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

      it 'returns a bad request response when shipment id invalid : integer string with spaces' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        get '/companies/4/shipments/%201%20', headers: headers

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

