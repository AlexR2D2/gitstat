defmodule ApiClient do

  @time_to_sleep 333

  # result key-value format: [modula2: 102, cobol: 592, ada: 1897, crystal: 2310]
  @spec total_stats(List.t) :: {:ok, list()} | {:error, list()}
  def total_stats(languages) do
    Enum.reduce(languages, {:ok, []}, fn language, acc ->       
      
      Process.sleep(@time_to_sleep) # to prevent abusing by github

      with {:ok, stats} <- acc,
           {:ok, %{search: %{repositoryCount: count}}} <- HttpClient.post_ql(GraphQL.build_query(language)) do
        {:ok, [{language.key, count}] ++ stats}
      end
    end)
  end

  @spec daily_stats(List.t) :: List.t 
  def daily_stats(languages) do
    Enum.to_list(1..7)
    |> Enum.reduce([], fn offset, acc -> acc ++ [Timex.shift(Timex.today, days: -offset)] end)
    |> Enum.reduce({:ok, []}, fn day, acc -> 
        
      Process.sleep(@time_to_sleep) # to prevent abusing by github
      
      with {:ok, total_stats} <- acc,
           {:ok, daily_stats} <- HttpClient.post_ql(GraphQL.build_query(languages, day)) do
        {:ok, [{day, Enum.map(daily_stats, fn {key, %{repositoryCount: count}} -> {key, count} end)}] ++ total_stats}
      end
    end)
  end

  @spec weekly_stats(List.t) :: List.t 
  def weekly_stats(languages) do  
    generate_weeks()
    |> Enum.reduce({:ok, []}, fn %{weekEnd: weekEnd, weekBeg: weekBeg} = week, acc ->        
        
      Process.sleep(@time_to_sleep) # to prevent abusing by github
      
      with {:ok, total_stats} <- acc,
           {:ok, weekly_stats} <- HttpClient.post_ql(GraphQL.build_query(languages, weekBeg, weekEnd)) do
        {:ok, [{week, Enum.map(weekly_stats, fn {key, %{repositoryCount: count}} -> {key, count} end)}] ++ total_stats}
      end
    end)
  end
  
  @spec monthly_stats(List.t) :: List.t 
  def monthly_stats(languages) do
    generate_months()
    |> Enum.reduce({:ok, []}, fn %{monthBeg: monthBeg, monthEnd: monthEnd, monthName: monthName} = month, acc ->         
        
      Process.sleep(@time_to_sleep) # to prevent abusing by github

      with {:ok, total_stats} <- acc,
           {:ok, monthly_stats} <- HttpClient.post_ql(GraphQL.build_query(languages, monthBeg, monthEnd)) do

        {:ok, [{month, Enum.map(monthly_stats, fn {key, %{repositoryCount: count}} -> {key, count} end)}] ++ total_stats}
      end
    end)
  end

  @spec monthly_stats(List.t) :: List.t 
  def yearly_stats(languages) do
    generate_years()
    |> Enum.reduce({:ok, []}, fn %{yearBeg: yearBeg, yearEnd: yearEnd, yearName: yearName} = year, acc ->         
        
        Process.sleep(@time_to_sleep) # to prevent abusing by github

        with {:ok, total_stats} <- acc,
             {:ok, yearly_stats} <- yearly_stats(languages, yearBeg, yearEnd) do
          {:ok, [{year, yearly_stats}] ++ total_stats}
        end
    end)
  end

  defp yearly_stats(languages, yearBeg, yearEnd) do
    Enum.reduce(languages, {:ok, []}, fn language, acc -> 
      
      Process.sleep(@time_to_sleep) # to prevent abusing by github

      with {:ok, total_stats} <- acc,
           {:ok, %{search: %{repositoryCount: count}}} <- HttpClient.post_ql(GraphQL.build_query(language, yearBeg, yearEnd)) do
        {:ok, [{language.key, count}] ++ total_stats}      
      end
    end)   
  end

  # tools
  
  defp generate_weeks do
    today = Timex.today()
    day_of_week = Calendar.ISO.day_of_week(today.year, today.month, today.day)    
    weekEnd = today
    weekBeg = Timex.shift(today, days: 1 - day_of_week)
    {year, weekName} = Elixir.Timex.iso_week(weekBeg)
    currentWeek = %{weekEnd: today, weekBeg: weekBeg, weekName: weekName}
    Enum.to_list(1..6)
    |> Enum.reduce([currentWeek], fn _offset, [week | t] = acc ->
      prevWeekEnd = Timex.shift(week.weekBeg, days: -1)
      prevWeekBeg = Timex.shift(prevWeekEnd, days: -6)
      {year, weekName} = Elixir.Timex.iso_week(prevWeekBeg)      
      [%{weekEnd: prevWeekEnd, weekBeg: prevWeekBeg, weekName: weekName}] ++ acc
    end)
    |> Enum.reverse  
  end

  defp generate_months do
    today = Timex.today()
    monthEnd = today
    monthBeg = Timex.beginning_of_month(monthEnd)
    monthName = Timex.month_shortname(monthBeg.month)
    currentMonth = %{monthBeg: monthBeg, monthEnd: monthEnd, monthName: monthName}
    Enum.to_list(1..6)
    |> Enum.reduce([currentMonth], fn _offset, [month | t] = acc ->       
      monthBeg = Timex.shift(month.monthBeg, months: -1)
      monthEnd = Timex.end_of_month(monthBeg)
      monthName = Timex.month_shortname(monthBeg.month)
      [%{monthBeg: monthBeg, monthEnd: monthEnd, monthName: monthName}] ++ acc
    end)
    |> Enum.reverse  
  end

  defp generate_years do
    today = Timex.today()
    yearEnd = today
    yearBeg = Timex.beginning_of_year(yearEnd)
    yearName = yearBeg.year
    currentYear = %{yearBeg: yearBeg, yearEnd: yearEnd, yearName: yearName}
    Enum.to_list(1..6)
    |> Enum.reduce([currentYear], fn _offset, [year | t] = acc ->
      yearBeg = Timex.shift(year.yearBeg, years: -1)
      yearEnd = Timex.end_of_year(yearBeg)
      yearName = yearBeg.year
      [%{yearBeg: yearBeg, yearEnd: yearEnd, yearName: yearName}] ++ acc
    end)
    |> Enum.reverse  
  end

end
