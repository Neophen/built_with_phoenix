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
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :url, :string do
      allow_nil? false
      public? true
    end

    attribute :logo, :string, public?: true
    attribute :description, :string, public?: true

    attribute :status, BuiltWithPhoenix.Organizations.OrganizationStatus,
      public?: true,
      default: :new
  end

  relationships do
    many_to_many :organizations, Organization do
      through OrganizationTechnology
      source_attribute_on_join_resource :technology_id
      destination_attribute_on_join_resource :organization_id
    end
  end

  calculations do
    calculate :has_organizations, :boolean, expr(
      count(organizations, query: [filter: expr(status == ^:active)]) > 0
    )
  end


  actions do
    defaults [:read, :destroy]

    read :available do
      filter expr(status == :active and has_organizations)
    end

    create :create do
      accept [
        :name,
        :url,
        :logo,
        :description
      ]
    end

    update :update do
      accept [
        :name,
        :url,
        :logo,
        :description
      ]
    end

    update :approve do
      change set_attribute(:status, :active)
    end

    update :decline do
      change set_attribute(:status, :declined)
    end

    read :active do
      filter expr(status == :active)
    end
  end
end
