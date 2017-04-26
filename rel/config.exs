use Mix.Releases.Config,
  default_release: :default,
  default_environment: :default

cookie = :sha256
|> :crypto.hash(System.get_env("ERLANG_COOKIE") || "fAr7DOo7KgNb8m2upPMHP/AI0YZlewWY015rGyrEgffREDjPMwu/P0YaVUPW4cyF")
|> Base.encode64

environment :default do
  set pre_start_hook: "bin/hooks/pre-start.sh"
  set dev_mode: false
  set include_erts: false
  set include_src: false
  set cookie: cookie
end

release :mithril_api do
  set version: current_version(:mithril_api)
  set applications: [
    mithril_api: :permanent
  ]
end
