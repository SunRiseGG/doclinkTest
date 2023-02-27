defmodule Records do
  import Record
  require KVS

  defrecord(:routeProc, id: [], operation: [], feed: [], type: [], folder: [], users: [], folderType: [], callback: [], reject: [], options: [])
  defrecord(:doclink_ref, id: [], folder: [], pid: [], userId: [], user: [], type: [], feed: [], permanent: [], folderPrefix: [], reject: [])
  defrecord(:doclink, id: [], attachment: [], docnum: [], doctype: [], step: [], proc: [], mon: [], etc: [], visited: [], star: [], opened: [], moved: [])
  defrecord(:tabInfo, id: [], name: [], feed: [], type: [])
  defrecord(:testDoc, id: [], name: [])
  defrecord(:employee, id: [], name: [])
  defrecord(:lock, id: [], feed: [])

  def metainfo(), do: KVS.schema(name: Records, tables: tables())
  def tables(), do: [KVS.table(name: :doclink, fields: Keyword.keys(doclink(doclink())), instance: doclink()),
                     KVS.table(name: :testDoc, fields: Keyword.keys(testDoc(testDoc())), instance: testDoc()),
                     KVS.table(name: :employee, fields: Keyword.keys(employee(employee())), instance: employee()),
                     KVS.table(name: :doclink_ref, fields: Keyword.keys(doclink_ref(doclink_ref())), instance: doclink_ref(), keys: Keyword.keys(doclink_ref(doclink_ref()))),
                     KVS.table(name: :lock, fields: Keyword.keys(lock(lock())), instance: lock(), keys: Keyword.keys(lock(lock()))),
                     KVS.table(name: :tabInfo, fields: Keyword.keys(tabInfo(tabInfo())), instance: tabInfo()),
                     KVS.table(name: :routeProc, fields: Keyword.keys(routeProc(routeProc())), instance: routeProc())]

end