defmodule Storage do
  use GenServer  

  @db Database

  # client api

  def get_languages do
    Language.list()
  end

  # total stats

  def save_total_stats(total_stats), do: GenServer.call(__MODULE__, {:save, :total, total_stats})
  def get_total_stats(), do: GenServer.call(__MODULE__, {:stats, :total})
  def get_total_stats_date(), do: GenServer.call(__MODULE__, {:stats_date, :total})
  
  # daily stats

  def save_daily_stats(daily_stats), do: GenServer.call(__MODULE__, {:save, :daily, daily_stats})
  def get_daily_stats(), do: GenServer.call(__MODULE__, {:stats, :daily})
  def get_daily_stats_date(), do: GenServer.call(__MODULE__, {:stats_date, :daily})

  # weekly stats

  def save_weekly_stats(weely_stats), do: GenServer.call(__MODULE__, {:save, :weekly, weely_stats})
  def get_weekly_stats, do: GenServer.call(__MODULE__, {:stats, :weekly})
  def get_weekly_stats_date(), do: GenServer.call(__MODULE__, {:stats_date, :weekly})

  # monthly stats

  def save_monthly_stats(monthly_stats), do: GenServer.call(__MODULE__, {:save, :monthly, monthly_stats})
  def get_monthly_stats, do: GenServer.call(__MODULE__, {:stats, :monthly})
  def get_monthly_stats_date(), do: GenServer.call(__MODULE__, {:stats_date, :monthly})

  # yearly stats

  def save_yearly_stats(yearly_stats), do: GenServer.call(__MODULE__, {:save, :yearly, yearly_stats})
  def get_yearly_stats, do: GenServer.call(__MODULE__, {:stats, :yearly})
  def get_yearly_stats_date(), do: GenServer.call(__MODULE__, {:stats_date, :yearly})

  # gen_server  implementation

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    send self(), {:initializing}
    {:ok, state}
  end

  def handle_info({:initializing}, _state) do  
    {:noreply, @db.initialize()}
  end  

  def handle_call({:save, resolution, stats}, from, state) do
    Task.start(fn ->
      date = case resolution do
        :total ->   @db.save_total_stats({Timex.today(), stats})
        :daily ->   @db.save_daily_stats({Timex.today(), stats})
        :weekly ->  @db.save_weekly_stats({Timex.today(), stats})
        :monthly -> @db.save_monthly_stats({Timex.today(), stats})
        :yearly ->  @db.save_yearly_stats({Timex.today(), stats})
      end
      GenServer.reply(from, date) 
    end)
    {:noreply, state}
  end

  def handle_call({:stats_date, resolution}, from, state) do
    Task.start(fn ->
      date = case resolution do
        :total -> @db.get_total_stats_date()
        :daily -> @db.get_daily_stats_date()
        :weekly -> @db.get_weekly_stats_date()
        :monthly -> @db.get_monthly_stats_date()
        :yearly -> @db.get_yearly_stats_date()
      end
      GenServer.reply(from, date) 
    end)
    {:noreply, state}
  end

  def handle_call({:stats, resolution}, from, state) do
    Task.start(fn ->
      date = case resolution do
        :total -> @db.get_total_stats()
        :daily -> @db.get_daily_stats()
        :weekly -> @db.get_weekly_stats()
        :monthly -> @db.get_monthly_stats()
        :yearly -> @db.get_yearly_stats()
      end
      GenServer.reply(from, date) 
    end)
    {:noreply, state}
  end

end
