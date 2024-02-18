class ShipmentsController < ApplicationController
  def index
    @shipments = Shipment.all
  end

  def show
    validator = ShipmentParamsValidator.new(params)
    return render_bad_request("Missing required parameters 'id' and 'company_id'") unless validator.valid_for_show_action?

    @shipment = Shipment.find_by(id: params[:id], company_id: params[:company_id])
    return if @shipment

    render_resource_not_found("Couldn't find Shipment with 'id'=#{params[:id]} and 'company_id'=#{params[:company_id]}")
  end

  private

  def render_bad_request(message)
    render json: { error: 'Bad Request', message: message }, status: :bad_request
  end

  def render_resource_not_found(message)
    render json: { error: 'Resource not found', message: message }, status: :not_found
  end
end
