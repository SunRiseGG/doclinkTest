defmodule Test.Proc do
  require BPE
  require KVS
  import Doclink
  import Records

  def def(), do: BPE.xml("/priv/bpmn/testProc.bpmn")
  def auth(_roles), do: true

  def action({:request, _, _} = r, BPE.process(executors: e) = proc), do:
    BPE.result(type: :stop, state: generalAction(r, proc, proc), executed: e)
  def action({:request, _, _}, proc), do: BPE.result(type: :stop, state: proc)

  def generalAction(request, BPE.process(docs: [doc | _]) = proc, newState), do:
    (generalMove(request, proc, doc); newState)
  def generalAction(_, _, _), do: []

  def generalMove(r, proc, doc, routeType \\ "personal"), do:
    move(proc, doc, routeFrom(r, routeType), routeTo(r, routeType))

  def move(proc, doc, f, t), do: move_doclink(proc, doc, route(f, t))

  def routeFrom({:request, 'Test1', 'Test2'}, fT), do:
    [routeProc(folder: "test1", folderType: fT)]
  def routeFrom({:request, 'Test2', 'Test3'}, fT), do:
    [routeProc(folder: "test2", folderType: fT)]
  def routeFrom({:request, 'Test3', _}, fT), do:
    [routeProc(folder: "test3", folderType: fT)]
  def routeFrom(_,_), do: []

  def routeTo({:request, 'Created', 'Test1'}, fT), do:
    [routeProc(folder: "test1", folderType: fT)]
  def routeTo({:request, 'Test1', 'Test2'}, fT), do:
    [routeProc(folder: "test2", folderType: fT)]
  def routeTo({:request, 'Test2', 'Test3'}, fT), do:
    [routeProc(folder: "test3", folderType: fT)]
  def routeTo(_, _), do: []

  def executors(_, _), do: []

end
