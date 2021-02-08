defmodule EctoLiveView.Repo do
  use Ecto.Repo,
    otp_app: :ecto_live_view,
    adapter: Ecto.Adapters.Postgres
end
