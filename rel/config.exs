Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  default_release: :default,
  default_environment: Mix.env()

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"#{System.get_env("COOKIE")}"
  set vm_args: "./rel/vm.args"
end

release :smache do
  set version: current_version(:smache)
  set applications: [
    :runtime_tools
  ]
end
