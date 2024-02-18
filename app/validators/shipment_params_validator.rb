class ShipmentParamsValidator
  def initialize(params)
    @params = params
  end

  def valid_for_show_action?
    @params[:id].present? && @params[:company_id].present?
  end
end
