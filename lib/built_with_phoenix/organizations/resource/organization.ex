defmodule BuiltWithPhoenix.Organizations.Resource.Organization do
  use Ash.Resource,
    domain: BuiltWithPhoenix.Organizations,
    data_layer: AshPostgres.DataLayer

  alias BuiltWithPhoenix.Organizations.Resource.Technology
  alias BuiltWithPhoenix.Organizations.Resource.OrganizationTechnology

  postgres do
    table "organizations"
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
    attribute :image, :string, public?: true
    attribute :usage_public, :string, public?: true
    attribute :usage_private, :string, public?: true
    attribute :description, :string, public?: true
    attribute :extra_sites, :string, public?: true
    attribute :author_name, :string, public?: true
    attribute :author_email, :string, public?: true
    attribute :weight, :integer, public?: true, default: 0

    attribute :status, BuiltWithPhoenix.Organizations.OrganizationStatus,
      public?: true,
      default: :new
  end

  relationships do
    many_to_many :technologies, Technology do
      through OrganizationTechnology
      source_attribute_on_join_resource :organization_id
      destination_attribute_on_join_resource :technology_id
    end
  end

  code_interface do
    define :active
    define :approve
    define :get_by_id, action: :by_id, args: [:id], get?: true
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [
        :name,
        :url,
        :logo,
        :image,
        :usage_public,
        :usage_private,
        :description,
        :extra_sites,
        :author_name,
        :author_email
      ]

      argument :technologies, {:array, :uuid_v7} do
        allow_nil? false
      end

      change manage_relationship(:technologies, type: :append_and_remove)
    end

    update :update do
      require_atomic? false

      accept [
        :name,
        :weight,
        :url,
        :logo,
        :image,
        :usage_public,
        :usage_private,
        :description,
        :extra_sites,
        :author_name,
        :author_email
      ]

      argument :technologies, {:array, :uuid_v7} do
        allow_nil? false
      end

      change manage_relationship(:technologies, type: :append_and_remove)
    end

    update :approve do
      change set_attribute(:status, :active)
    end

    update :decline do
      change set_attribute(:status, :declined)
    end

    read :active do
      argument :technology_ids, {:array, :uuid_v7} do
        allow_nil? true
        default nil
      end

      filter expr(status == :active)
      filter expr(is_nil(^arg(:technology_ids)) or technologies.id in ^arg(:technology_ids))
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end
  end
end
