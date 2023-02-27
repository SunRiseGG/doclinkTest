use Mix.Config

config :bpe,
  ttl: :infinity,
  ping_discipline: :undefined,
  shutdown_timeout: 20000,
  timeout: 30000,
  procmodules: [Test.Proc],
  logger_level: :error,
  logger: [
    {:handler, :synrc, :logger_std_h,
     %{
       level: :debug,
       id: :synrc,
       max_size: 2000,
       module: :logger_std_h,
       config: %{type: :file, file: 'testTask.log'},
       formatter:
         {:logger_formatter,
          %{
            template: [:time, ' ', :pid, ' ', :module, ' ', :msg, '\n'],
            single_line: true
          }}
     }}
  ]

config :n2o,
  pi_call_timeout: :infinity,
  pickler: AES.GCM,
  mq: :n2o_syn,
  port: 50111,
  app: :testTask,
  session: :n2o_session,
  ttl: 60 * 60 * 8,
  nitro_prolongate: false,
  mqtt_host: [],
  mqtt_tcp_port: 1883,
  mqtt_services: [],
  ws_services: [],
  tables: [:cookies, :file, :web, :caching, :ws, :mqtt, :tcp, :async, :edit]

config :kvs,
  dba: :kvs_rocks,
  dba_st: :kvs_st,
  dba_seq: :kvs_mnesia,
  seq_pad: [:doclink, :process],
  schema: [:kvs, :kvs_stream, :bpe_metainfo, :"Elixir.Records"]
