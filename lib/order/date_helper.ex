defmodule Order.DateHelper do
  def in_range?(range, date) do
    gte_lower =
      if is_nil(range.lower) || range.lower == :unbound do
        true
      else
        comp = Date.compare(date, range.lower)
        comp == :gt or comp == :eq
      end

    lte_upper =
      if is_nil(range.upper) or range.upper == :unbound do
        true
      else
        comp = Date.compare(date, range.upper)
        comp == :lt or comp == :eq
      end

    gte_lower and lte_upper
  end
end
