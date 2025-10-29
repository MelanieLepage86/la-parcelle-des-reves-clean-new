module ApplicationHelper
  def bootstrap_badge_class(status)
    case status
    when "pending"
      "bg-danger text-light"
    when "termine"
      "bg-success text-light"
    else
      "bg-warning text-dark"
    end
  end
end
