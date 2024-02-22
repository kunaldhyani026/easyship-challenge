class ShipmentParamsValidator
  def initialize(params)
    @params = params
  end

  def validate
    action = @params[:action]
    case action
    when 'show'
      valid_for_show_action?
    else
      # default validation is false, to ensure not allow anyone bypass validation without writing validation logic
      false
    end
  end

  private

  # This method checks that params for show action are valid or not
  def valid_for_show_action?
    integer?(@params[:id]) && integer?(@params[:company_id])
  end

  # This method checks that provided value is integer without any other string character or leading zeroes
  def integer?(value)
    value.to_i.to_s == value.to_s
  end
end
