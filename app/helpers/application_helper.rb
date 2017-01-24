module ApplicationHelper
  def render_errors(object)
    render "shared/error_messages", object: object
  end

  def flash_class flash_type
    case flash_type.to_sym
    when :success
      "alert-success"
    when :error, :alert, :danger
      "alert-danger"
    when :notice
      "alert-info"
    else
      "alert-warning"
    end
  end
end
