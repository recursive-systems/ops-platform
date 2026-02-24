defmodule OpsPlatform.Finance.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :schedule_c_line, :string
    field :description, :string
    field :tax_deductible, :boolean, default: false

    belongs_to :organization, OpsPlatform.Accounts.Organization
    has_many :transactions, OpsPlatform.Finance.Transaction

    timestamps(type: :utc_datetime)
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :schedule_c_line, :description, :tax_deductible, :organization_id])
    |> validate_required([:name, :organization_id])
  end
end
