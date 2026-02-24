defmodule OpsPlatform.Accounts.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :name, :string
    field :slug, :string
    field :settings, :map, default: %{}

    has_many :users, OpsPlatform.Accounts.User
    has_many :tax_years, OpsPlatform.Finance.TaxYear
    has_many :accounts, OpsPlatform.Finance.Account
    has_many :categories, OpsPlatform.Finance.Category
    has_many :documents, OpsPlatform.Finance.Document

    timestamps(type: :utc_datetime)
  end

  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug, :settings])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase alphanumeric with dashes"
    )
  end
end
