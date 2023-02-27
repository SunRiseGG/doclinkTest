defmodule BOOT do
  import Records

  def boot(), do:
    :lists.foreach(&:kvs.append(&1, "/tabs"), tabs())

  def tabs(), do:
    [tabInfo(id: 'test1', name: 'test1', feed: fn (_, _) -> "/tab/system/test1" end, type: :system),
     tabInfo(id: 'test2', name: 'test2', feed: fn (_, _) -> "/tab/system/test2" end, type: :system),
     tabInfo(id: 'test3', name: 'test3', feed: fn (_, _) -> "/tab/system/test3" end, type: :system)]

end