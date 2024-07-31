defmodule BuiltWithPhoenix.Repo do
  use AshPostgres.Repo, otp_app: :built_with_phoenix

  # Installs extensions that ash commonly uses
  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext"]
  end
end
