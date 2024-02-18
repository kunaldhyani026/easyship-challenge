class ShipmentsController < ApplicationController
  def index
    @shipments = Shipment.all
  end

  def show
    @shipment = Shipment.find_by(id: params[:id], company_id: params[:company_id])
    return if @shipment

    error_message = "Couldn't find Shipment with 'id'=#{params[:id]} and 'company_id'=#{params[:company_id]}"
    render_resource_not_found('Shipment not found', error_message)
  end

  private

  def render_resource_not_found(error, message)
    render json: { error: error, message: message }, status: :not_found
  end
end
