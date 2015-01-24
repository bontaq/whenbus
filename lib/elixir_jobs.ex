defmodule ElixirJobs do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
      tree = [worker(Whenbus.Repo, [])]
      opts = [name: Whenbus.Sup, strategy: :one_for_one]
      Supervisor.start_link(tree, opts)
  end
end
