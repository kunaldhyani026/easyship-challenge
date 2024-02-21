class ShipmentsController < ApplicationController
  before_action :validate_params, only: [:show]

  def index
    @shipments = Shipment.all
  end

  def show
    @shipment = Shipment.includes(:shipment_items).find_by(id: params[:id], company_id: params[:company_id])
    return if @shipment

    error_message = "Couldn't find Shipment with 'id'=#{params[:id]} and 'company_id'=#{params[:company_id]}"
    render_error('resource_not_found', 'invalid_request_error', error_message, 404)
  end

  private

  def validate_params
    validator = ShipmentParamsValidator.new(params)
    return if validator.validate

    render_error('invalid_request', 'invalid_request_error', 'The request param are not valid.', 400)
  end

  def render_error(code, type, message, http_status_code)
    render json: { error: { code: code, message: message, type: type } }, status: http_status_code
  end
end
