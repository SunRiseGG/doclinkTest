defmodule Test do
  import Records
  require BPE
  require KVS

  def test() do
    procs = :lists.map(fn _ ->
      {:ok, pid} = :bpe.start(BPE.process(Test.Proc.def(), id: :erlang.list_to_binary(:kvs.seq(:process, 1))), [testDoc()])
      :bpe.next pid
      pid
    end, :lists.seq(1, 2000))
    :lists.foreach(fn pid ->
      spawn(fn ->
        t1 = :rand.uniform(50); t2 = :rand.uniform(200)
        :timer.apply_after(t1, :bpe, :next, [pid])
        :timer.apply_after(t2, :bpe, :next, [pid])
      end)
    end, procs)
  end

  def check(n) do
    KVS.writer(count: c1) = :kvs.writer("/tab/system/test1")
    KVS.writer(count: c2) = :kvs.writer("/tab/system/test2")
    KVS.writer(count: c3) = :kvs.writer("/tab/system/test3")
    c1 == 0 and c2 == 0 and c3 == n
  end

end