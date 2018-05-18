defmodule GuthubWatcherWeb.PageView do
  use GuthubWatcherWeb, :view

  def date_to_string(date) do
    "#{Integer.to_string(date.year - 2000)}/#{number_string(date.month)}/#{number_string(date.day)}"  
  end

  def date_to_string_mob(date) do
    "#{number_string(date.month)}/#{number_string(date.day)}"  
  end
  
  defp number_string(number), do: String.pad_leading(Integer.to_string(number), 2, "0")

end
