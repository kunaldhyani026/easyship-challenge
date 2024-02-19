class ShipmentParamsValidator
  def initialize(params)
    @params = params
  end

  # This method checks that id and company_id params has to be integer only.
  # Returns :
  #   - true if id and company_id params are only integers without any string character or leading zeroes
  #   - else false
  def valid_for_show_action?
    @params[:id].to_i.to_s == @params[:id].to_s && @params[:company_id].to_i.to_s == @params[:company_id].to_s
  end
end
