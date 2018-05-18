defmodule Database do 
  import Ex2ms

  # behaviour

  # impl

  @total_stats :total_stats 
  @daily_stats :daily_stats  
  @weekly_stats :weekly_stats
  @monthly_stats :monthly_stats  
  @yearly_stats :yearly_stats  

  def initialize do    
    {:ok, total_stats} = :dets.open_file(@total_stats, [type: :set])
    {:ok, daily_stats} = :dets.open_file(@daily_stats, [type: :set])
    {:ok, weekly_stats} = :dets.open_file(@weekly_stats, [type: :set])    
    {:ok, monthly_stats} = :dets.open_file(@monthly_stats, [type: :set])       
    {:ok, yearly_stats} = :dets.open_file(@yearly_stats, [type: :set])            
    %{
      yearly_stats: yearly_stats, 
      monthly_stats: monthly_stats, 
      weekly_stats: weekly_stats, 
      daily_stats: daily_stats, 
      stats: total_stats
    }
  end

  # total
  
  def save_total_stats({date, stats}) do
    stats_per_lang = Storage.get_languages()
    |> Enum.map(fn %{key: key, lang: language} -> %{key: key, label: language, stats: stats[key]} end)
    |> Enum.sort(fn %{stats: leftCount}, %{stats: rightCount} -> leftCount >= rightCount end)
    :dets.insert(@total_stats, {:stats, stats_per_lang})
    :dets.insert(@total_stats, {:date, date})
  end

  def get_total_stats, do: get_stats(@total_stats)
  def get_total_stats_date, do: get_stats_date(@total_stats)

  # daily

  def save_daily_stats({date, daily_stats}) do
    stats_per_lang = daily_stats
    |> Enum.sort(fn {leftDate, _}, {rightDate, _} -> leftDate < rightDate end)
    |> Enum.reduce({[], %{}}, fn {date, daily_stats}, {dates, stats} ->
      {[date] ++ dates, stats_per_language(daily_stats, stats)}
    end)
    :dets.insert(@daily_stats, {:stats, stats_per_lang})
    :dets.insert(@daily_stats, {:date, date})
  end

  def get_daily_stats, do: get_stats(@daily_stats)
  def get_daily_stats_date, do: get_stats_date(@daily_stats)

  # weekly

  def save_weekly_stats({date, weely_stats}) do
    stats_per_lang = weely_stats
    |> Enum.sort(fn {%{weekBeg: leftDate}, _}, {%{weekBeg: rightDate}, _} -> leftDate > rightDate end)
    |> Enum.reduce({[], %{}}, fn {week, weely_stats}, {weeks, stats} ->
      {[week] ++ weeks, stats_per_language(weely_stats, stats)}
    end)
    :dets.insert(@weekly_stats, {:stats, stats_per_lang})
    :dets.insert(@weekly_stats, {:date, date})    
  end

  def get_weekly_stats, do: get_stats(@weekly_stats)
  def get_weekly_stats_date, do: get_stats_date(@weekly_stats)

  # monthly

  def save_monthly_stats({date, monthly_stats}) do
    stats_per_lang = monthly_stats
    |> Enum.sort(fn {%{monthBeg: leftDate}, _}, {%{monthBeg: rightDate}, _} -> leftDate < rightDate end)
    |> Enum.reduce({[], %{}}, fn {month, monthly_stats}, {months, stats} ->
      {[month] ++ months, stats_per_language(monthly_stats, stats)}
    end)
    :dets.insert(@monthly_stats, {:stats, stats_per_lang})
    :dets.insert(@monthly_stats, {:date, date})    
  end

  def get_monthly_stats, do: get_stats(@monthly_stats)
  def get_monthly_stats_date, do: get_stats_date(@monthly_stats)

  # yearly

  def save_yearly_stats({date, yearly_stats}) do
    stats_per_lang = yearly_stats
    |> Enum.sort(fn {%{yearBeg: leftDate}, _}, {%{yearBeg: rightDate}, _} -> leftDate < rightDate end)
    |> Enum.reduce({[], %{}}, fn {year, yearly_stats}, {years, stats} ->
      {[year] ++ years, stats_per_language(yearly_stats, stats)}
    end)
    :dets.insert(@yearly_stats, {:stats, stats_per_lang})
    :dets.insert(@yearly_stats, {:date, date})    
  end

  def get_yearly_stats, do: get_stats(@yearly_stats)
  def get_yearly_stats_date, do: get_stats_date(@yearly_stats)

  # impl

  defp stats_per_language(langs_stats, acc) do
    Enum.reduce(langs_stats, acc, fn {key, repos_count}, acc -> 
      case acc[key] do
        nil ->
          Map.put(acc, key, [repos_count])
        repos_count_list ->
          Map.put(acc, key, [repos_count] ++ repos_count_list)
      end        
    end)  
  end

  defp get_stats(table) do
    with [stats: stats] <- :dets.lookup(table, :stats) do
      stats
    else 
      [] -> nil
    end
  end

  defp get_stats_date(table) do
    with [date: date] <- :dets.lookup(table, :date) do 
      date
    else 
      [] -> nil
    end
  end

end
