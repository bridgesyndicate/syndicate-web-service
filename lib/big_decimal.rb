class BigDecimal
  def to_json(*args)
    to_f == to_i ? "#{to_i}" : "#{to_f}"
  end
end
