defmodule BuiltWithPhoenix.Organizations.Resource.Technology do
  use Ash.Resource,
    domain: BuiltWithPhoenix.Organizations,
    data_layer: AshPostgres.DataLayer

  alias BuiltWithPhoenix.Organizations.Resource.Organization
  alias BuiltWithPhoenix.Organizations.Resource.OrganizationTechnology

  postgres do
    table "technologies"
    repo BuiltWithPhoenix.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :url, :string do
      allow_nil? false
      public? true
    end

    attribute :image_url, :string, public?: true
  end

  relationships do
    many_to_many :organizations, Organization do
      through OrganizationTechnology
      source_attribute_on_join_resource :technology_id
      destination_attribute_on_join_resource :organization_id
    end
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
