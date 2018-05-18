defmodule GuthubWatcher do
  require Logger

  @storage Storage
  @github_client ApiClient
  
  # TODO call update in parallel !

  def update do  
    update_total_stats()
    update_daily_stats()
    update_weekly_stats()
    update_monthly_stats()
    update_yearly_stats()
  end

  # total

  def update_total_stats do
    Logger.debug "updating total stats..."
    languages = @storage.get_languages()
    with {:ok, stats} <- @github_client.total_stats(languages), do:
      @storage.save_total_stats(stats)
  end  

  def get_total_stats, do: @storage.get_total_stats()
  def get_total_stats_date, do: @storage.get_total_stats_date()

  # daily

  def update_daily_stats do
    Logger.debug "updating daily stats..."
    languages = @storage.get_languages()
    with {:ok, stats} <- @github_client.daily_stats(languages), do:
      @storage.save_daily_stats(stats)
  end      

  def get_daily_stats, do: @storage.get_daily_stats()
  def get_daily_stats_date, do: @storage.get_daily_stats_date()

  # weekly

  def update_weekly_stats do
    Logger.debug "updating weekly stats..."
    languages = @storage.get_languages()
    with {:ok, stats} <- @github_client.weekly_stats(languages), do:
      @storage.save_weekly_stats(stats)
  end      

  def get_weekly_stats, do: @storage.get_weekly_stats()
  def get_weekly_stats_date, do: @storage.get_weekly_stats_date()

  # monthly

  def update_monthly_stats do
    Logger.debug "updating monthly stats..."
    languages = @storage.get_languages()  
    with {:ok, stats} <- @github_client.monthly_stats(languages), do:
      @storage.save_monthly_stats(stats)
  end

  def get_monthly_stats, do: @storage.get_monthly_stats()
  def get_monthly_stats_date, do: @storage.get_monthly_stats_date()

  # yearly

  def update_yearly_stats do
    Logger.debug "updating yearly stats..."
    languages = @storage.get_languages()  
    with {:ok, stats} <- @github_client.yearly_stats(languages), do: 
      @storage.save_yearly_stats(stats)
  end

  def get_yearly_stats, do: @storage.get_yearly_stats()
  def get_yearly_stats_date, do: @storage.get_yearly_stats_date()

end
