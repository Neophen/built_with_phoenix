defmodule BuiltWithPhoenix.Organizations.Resource.OrganizationTechnology do
  use Ash.Resource,
    domain: BuiltWithPhoenix.Organizations,
    data_layer: AshPostgres.DataLayer

  alias BuiltWithPhoenix.Organizations.Resource.Technology
  alias BuiltWithPhoenix.Organizations.Resource.Organization

  postgres do
    table "technologies_organizations"
    repo BuiltWithPhoenix.Repo
  end

  relationships do
    belongs_to :technology, Technology, primary_key?: true, allow_nil?: false
    belongs_to :organization, Organization, primary_key?: true, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
