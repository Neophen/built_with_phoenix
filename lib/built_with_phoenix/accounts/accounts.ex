defmodule BuiltWithPhoenix.Accounts do
  use Ash.Domain

  resources do
    resource BuiltWithPhoenix.Accounts.Resource.User
    resource BuiltWithPhoenix.Accounts.Resource.Token
  end
end
