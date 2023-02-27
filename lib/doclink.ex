defmodule Doclink do
  require BPE
  require N2O
  require KVS
  import Records

  def route(routeFrom, routeTo), do:
    (t = parseRoute(:to, routeTo);
    :lists.filter(&(:lists.keyfind(routeProc(&1, :feed), routeProc(:feed) + 1, t) == false), parseRoute(:from, routeFrom)) ++ t)

  def move_doclink(proc, doc, route), do: move_doclink(proc, doc, route, %{})
  def move_doclink(proc, doc, [routeProc() | _] = route, ext), do: :lists.map(&move_doclink(proc, doc, &1, ext), route)
  def move_doclink(proc, doc, routeProc(options: [], folder: folder, users: u, reject: r, folderType: fT, type: rT) = x, ext), do:
    move_doclink(proc, doc, routeProc(x, options: options(tab(folder), folder, u, fT, r, rT)), ext)
  def move_doclink(proc, _, routeProc(operation: :from, options: opt), _), do:
    (prev = get_doclink(proc, opt, :from); delete_doclink(prev, opt); prev)
  def move_doclink(proc, doc, routeProc(operation: :to, options: %{:feed => feed} = opt, folder: folder, users: u, folderType: fT), ext), do:
    (prev_doclink = get_doclink(proc, opt, :to); doclink = doclink(proc, doc, folder, u, fT, ext, prev_doclink, opt);
     index_doclink(prev_doclink, doclink, opt); DoclinkPi.send(feed, folder, {:append, doclink}); doclink)
  def move_doclink(_, _, _, _), do: []

  defp parseRoute(o, route), do:
    :lists.map(fn routeProc(users: [], folder: f, folderType: fT, type: rT, reject: r) = x ->
                    t = tab(f); %{:feed => feed} = opt = options(t, f, [], fT, r, rT); routeProc(x, options: opt, operation: o, feed: feed)
                  routeProc(users: u, folder: f, folderType: fT, type: rT, reject: r) = x ->
                    u = :lists.filter(fn employee(id: id) -> id != [] end, u);
                    tab = tab(f); :lists.map(fn u -> %{:feed => feed} = opt = options(tab, f, u, fT, r, rT); routeProc(x, options: opt, operation: o, users: u, feed: feed) end, u)
                  end, route) |> Enum.filter(fn routeProc(feed: []) -> false; _ -> true end) |> :lists.flatten()

  defp tab(f), do: (case :kvs.get("/tabs", :nitro.to_list(f)) do {:ok, tabInfo() = x} -> x; _ -> [] end)

  defp index_doclink(doclink(), _, _), do: []
  defp index_doclink(_, doclink(id: i, proc: p), %{:feed => feed, :permanent => per, :folderType => fT, :folder => f, :user => u, :reject => r, :tab => tabInfo(type: t)}), do:
    :kvs.put(doclink_ref(id: i, pid: p, folder: f, permanent: per, folderPrefix: fT, reject: r, user: t == :system && [] || u, userId: t == :system && [] || :erlang.element(2, u), type: t, feed: feed), KVS.kvs(mod: :kvs_mnesia))

  defp clean_index(doclink(id: i)), do: :kvs.delete(:doclink_ref, i, KVS.kvs(mod: :kvs_mnesia))
  defp clean_index(doclink_ref(id: i)), do: :kvs.delete(:doclink_ref, i, KVS.kvs(mod: :kvs_mnesia))

  defp get_doclink(_, %{:feed => []}, _), do: []
  defp get_doclink(_, %{:type => :personal, :user => []}, _), do: []
  defp get_doclink(BPE.process(id: pid), %{:feed => feed, :folder => f, :user => u, :tab => tabInfo(type: t)}, _), do:
    (case :kvs.index_match(doclink_ref(id: :_, permanent: :_, folder: f, folderPrefix: :_, pid: pid, user: :_, reject: :_, userId: t == :system && [] || :erlang.element(2, u), type: t, feed: feed), :pid, KVS.kvs(mod: :kvs_mnesia)) do
      [doclink_ref(id: i) | _] -> case :kvs.get(feed, i) do {:ok, x} -> x; _ -> [] end;
      _ -> []
    end)

  defp delete_doclink(doclink() = x, %{:feed => feed, :folder => f}), do: (DoclinkPi.send(feed, f, {:remove, x}); clean_index(x); x)
  defp delete_doclink(doclink_ref(id: id, feed: feed) = x, %{:folder => f}), do:
    (case :kvs.get(feed, id) do {:ok, d} -> DoclinkPi.send(feed, f, {:remove, d}); clean_index(x); d; _ -> x end)
  defp delete_doclink(x, _), do: x

  defp doclink(BPE.process(monitor: mon), d, _, _, _, _, doclink() = x, _), do:
    doclink(x, mon: mon, docnum: :erlang.element(2, d))
  defp doclink(BPE.process(id: pid, monitor: mon), doc, _, _, _, _, _, _), do:
    doclink(
      id: :kvs.seq(:doclink, 1),
      doctype: :erlang.element(1, doc),
      docnum: :erlang.element(2, doc),
      proc: pid,
      mon: mon,
      star: false,
      visited: false
    )

  defp options(tabInfo(type: t) = tab, f, u, fT, reject, routeType), do:
    %{:reject => reject, :type => t, :permanent => routeType == :permanent, :tab => tab, :user => u, :feed => feed(fT, tab), :folder => f, :folderType => fT}

  def feed(type, tabInfo(feed: feedFn)), do: feedFn.(type, [])
  def feed(_, _), do: []
end
