defmodule BuiltWithPhoenix.Organizations.OrganizationStatus do
  use Ash.Type.Enum, values: [:new, :active, :declined]
end
