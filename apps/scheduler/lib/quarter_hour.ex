defmodule QuarterHour do

  def fire(tasks), do: spawn(fn -> tasks.scrub_github() end)

end
