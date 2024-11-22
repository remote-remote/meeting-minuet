defmodule MeetingMinuet.DateHelper do
  @doc """
  Returns true if the given date is within the given range.
  """
  def in_range?(%Postgrex.Range{} = range, %Date{} = date) do
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

  def lte?(nil, _), do: true
  def lte?(_, nil), do: true

  def lte?(%Date{} = date1, %Date{} = date2) do
    comp = Date.compare(date1, date2)
    comp == :lt or comp == :eq
  end
end
