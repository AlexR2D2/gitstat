defmodule GuthubWatcher.Application do
  @moduledoc """
  The GuthubWatcher Application Service.

  The guthub_watcher system business domain lives in this application.

  Exposes API to clients such as the `GuthubWatcherWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      
    ], strategy: :one_for_one, name: GuthubWatcher.Supervisor)
  end
end
