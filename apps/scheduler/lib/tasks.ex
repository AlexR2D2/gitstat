defmodule Tasks do
  require Logger
  
  def scrub_github() do
    check_and_scrub(GuthubWatcher.get_total_stats_date(), &GuthubWatcher.update_total_stats/0)
    check_and_scrub(GuthubWatcher.get_daily_stats_date(), &GuthubWatcher.update_daily_stats/0)
    check_and_scrub(GuthubWatcher.get_weekly_stats_date(), &GuthubWatcher.update_weekly_stats/0)
    check_and_scrub(GuthubWatcher.get_monthly_stats_date(), &GuthubWatcher.update_monthly_stats/0)
    check_and_scrub(GuthubWatcher.get_yearly_stats_date(), &GuthubWatcher.update_yearly_stats/0)
  end

  defp check_and_scrub(last_update_date, update_fn) do
    case Timex.to_datetime(last_update_date) do
      {:error, :invalid_date} ->
        update_fn.()
      date_time ->
        cond do
          Timex.diff(Timex.now, date_time, :days) > 0 -> 
            update_fn.()
          true -> 
            :ok
        end
    end
  end

end
