defmodule GuthubWatcherWeb.PageController do
  use GuthubWatcherWeb, :controller

  def index(conn, %{"resolution" => resolution}) do  
    case GuthubWatcher.get_total_stats() do
      nil ->
        render conn, "no_stats.html"
      total_stats ->        
        total_date = GuthubWatcher.get_total_stats_date()
        case get_stats(resolution) do
          {"day",   {days, stats},   daily_date} ->
            render conn, "index.html", total_stats: total_stats, days: days,    stats: stats, total_date: total_date, stats_date: daily_date

          {"week",  {weeks, stats},  weekly_date} ->
            render conn, "index.html", total_stats: total_stats, weeks: weeks,  stats: stats, total_date: total_date, stats_date: weekly_date

          {"month", {months, stats}, monthly_date} ->
            render conn, "index.html", total_stats: total_stats, months: months, stats: stats, total_date: total_date, stats_date: monthly_date
          
          {"year",  {years, stats},  yearly_date} ->
            render conn, "index.html", total_stats: total_stats, years: years,   stats: stats, total_date: total_date, stats_date: yearly_date
          
          _ ->
            render conn, "no_stats.html"
        end
    end
  end

  def get_stats(resolution) do
    case resolution do
      "day"   -> {"day",   GuthubWatcher.get_daily_stats(),   GuthubWatcher.get_daily_stats_date()}
      "week"  -> {"week",  GuthubWatcher.get_weekly_stats(),  GuthubWatcher.get_weekly_stats_date()}
      "month" -> {"month", GuthubWatcher.get_monthly_stats(), GuthubWatcher.get_monthly_stats_date()}
      "year"  -> {"year",  GuthubWatcher.get_yearly_stats(),  GuthubWatcher.get_yearly_stats_date()}
    end
  end

  def index(conn, params), do: index(conn, Map.put(params, "resolution", "day"))

end
