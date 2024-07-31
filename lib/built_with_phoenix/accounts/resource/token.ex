defmodule BuiltWithPhoenix.Accounts.Resource.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource],
    # If using policies, enable the policy authorizer:
    # authorizers: [Ash.Policy.Authorizer],
    domain: BuiltWithPhoenix.Accounts

  postgres do
    table "tokens"
    repo BuiltWithPhoenix.Repo
  end

  # If using policies, add the following bypass:
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  # end
end
