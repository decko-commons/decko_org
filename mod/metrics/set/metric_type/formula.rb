include_set Abstract::Calculation
include_set Abstract::Hybrid

format :html do
  def value_type
    "Number"
  end

  def value_type_code
    :number
  end

  def thumbnail_metric_info
    "Formula"
  end
end
