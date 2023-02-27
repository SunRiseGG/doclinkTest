defmodule TestTask.Application do
  use Application
  require KVS

  def start(_, _) do
    :logger.add_handlers(:testTask)
    :kvs.join([], KVS.kvs(mod: :kvs_rocks, db: 'rocksdb'))
    :kvs.join([], KVS.kvs(mod: :kvs_mnesia))
    BOOT.boot()
    Supervisor.start_link([], strategy: :one_for_one, name: TestTask.Supervisor)
  end

end