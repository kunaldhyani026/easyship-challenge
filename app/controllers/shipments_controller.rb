class ShipmentsController < ApplicationController
  before_action :validate_params, only: [:show, :tracking, :search]

  def index
    @shipments = Shipment.all
  end

  def show
    @shipment = Shipment.includes(:shipment_items).find_by(id: params[:id], company_id: params[:company_id])
    return if @shipment

    error_message = "Couldn't find Shipment with 'id'=#{params[:id]} and 'company_id'=#{params[:company_id]}"
    render_error('resource_not_found', 'invalid_request_error', error_message, 404)
  end

  def tracking
    shipment = Shipment.find_by(id: params[:id], company_id: params[:company_id])
    error_message = "Couldn't find Shipment with 'id'=#{params[:id]} and 'company_id'=#{params[:company_id]}"
    return render_error('resource_not_found', 'invalid_request_error', error_message, 404) unless shipment

    # Retrieve tracking information
    @tracking_info = AftershipClient.get_tracking_info(shipment.tracking_number)
    process_tracking_info
  end

  def search
    @shipments = Shipment.includes(:shipment_items).where(company_id: params[:company_id], shipment_items_count: params[:shipment_items_size])
  end

  private

  def validate_params
    validator = ShipmentParamsValidator.new(params)
    return if validator.validate

    render_error('invalid_request', 'invalid_request_error', 'The request param are not valid.', 400)
  end

  def process_tracking_info
    return if @tracking_info[:meta][:code] == 200
    return render_error('resource_not_found', 'invalid_request_error', @tracking_info[:meta][:message], 404) if @tracking_info[:meta][:code] == 4004

    render_error('api_error', @tracking_info[:meta][:type], @tracking_info[:meta][:message], @tracking_info[:meta][:code])
  end

  def render_error(code, type, message, http_status_code)
    render json: { error: { code: code, message: message, type: type } }, status: http_status_code
  end
end
