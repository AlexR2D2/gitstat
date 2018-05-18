defmodule Startup do  

  def fire(tasks), do: spawn(fn -> tasks.scrub_github() end)  
  
end  
