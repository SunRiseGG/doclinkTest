defmodule DoclinkPi do
  require N2O
  require KVS
  import Records

  def terminateCheck(feed, id, name, state) do
    case :kvs.index(:lock, :feed, feed, KVS.kvs(mod: :kvs_mnesia)) do
      [lock(id: ^id)] ->
        :bpe.cache(:terminateLocks, {:terminate, name}, self()); :kvs.delete(:lock, id, KVS.kvs(mod: :kvs_mnesia))
        {:stop, :normal, state}
      [] -> :bpe.cache(:terminateLocks, {:terminate, name}, self()); {:stop, :normal, state}
      _ -> :kvs.delete(:lock, id, KVS.kvs(mod: :kvs_mnesia)); {:reply, :ok, state}
    end
  end

  def check(feed) do
    pid = :n2o_pi.pid(:async, feed)
    case :bpe.cache(:terminateLocks, {:terminate, feed}) do
      pid when is_pid(pid) -> pid #mock
      _ when is_pid(pid) ->
        case :kvs.index(:lock, :feed, feed, KVS.kvs(mod: :kvs_mnesia)) do
          x when length(x) <= 2 and is_pid(pid) -> pid #mock
          _ -> []
        end
      _ -> []
    end
  end

  def send(feed, folder, event) do
    id = :erlang.integer_to_binary(:erlang.unique_integer([:positive, :monotonic]))
    :kvs.put(lock(id: id, feed: feed), KVS.kvs(mod: :kvs_mnesia))
    check(feed)
    case start(feed, folder) do
      pid when is_pid(pid) ->
        case :n2o_pi.send(pid, {event, id}) do :ok -> []; e -> e end
      x -> x
    end
  end

  def start(feed, folder) do
    pi = N2O.pi(module: DoclinkPi, sup: :n2o, table: :async, state: {feed, folder}, name: feed, timeout: 5000, restart: :transient)
    case :n2o_pi.start(pi) do
      {:error, :already_present} -> case :supervisor.restart_child(:n2o, {:async, feed}) do {:ok, x} -> x; {:ok, x, _} -> x; {:error, :running} -> x = :n2o_pi.pid(:async, feed); IO.inspect([feed, x, self()],label: "RESTART"); x; e -> e end
      {:error, {:already_started, x}} -> x
      {:error, e} -> e
      {pid, _} when is_pid(pid) -> pid
    end
  end

  def proc(:init, N2O.pi(state: st, name: n) = pi), do:
    (:erlang.process_flag(:trap_exit, true); :bpe.cache(:terminateLocks, {:terminate, n}, :undefined); {:ok, N2O.pi(pi, state: st)})

  def proc({{:remove, doclink}, id}, N2O.pi(state: {feed, _}, name: name) = pi) do
    :kvs.remove(doclink, feed)
    terminateCheck(feed, id, name, pi)
  end

  def proc({{:append, doclink}, id}, N2O.pi(state: {feed, _}, name: name) = pi) do
    :kvs.append(doclink, feed)
    terminateCheck(feed, id, name, pi)
  end

  def proc(_, pi), do: {:stop, :normal, pi}

  def terminate(_, N2O.pi(name: n)), do:
    (:bpe.cache(:terminateLocks, {:terminate, n}, self()); :n2o.cache(:async, {:async, n}, :undefined))
end