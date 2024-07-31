defmodule BuiltWithPhoenix.Organizations do
  use Ash.Domain

  resources do
    resource BuiltWithPhoenix.Organizations.Resource.Organization
    resource BuiltWithPhoenix.Organizations.Resource.Technology
    resource BuiltWithPhoenix.Organizations.Resource.OrganizationTechnology
  end
end
