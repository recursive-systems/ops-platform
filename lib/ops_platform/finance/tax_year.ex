defmodule OpsPlatform.Finance.TaxYear do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tax_years" do
    field :year, :integer
    field :start_date, :date
    field :end_date, :date
    field :status, :string, default: "open"

    belongs_to :organization, OpsPlatform.Accounts.Organization
    has_many :tax_tasks, OpsPlatform.Finance.TaxTask
    has_many :documents, OpsPlatform.Finance.Document
    has_many :tax_documents, OpsPlatform.Finance.TaxDocument

    timestamps(type: :utc_datetime)
  end

  @valid_statuses ~w(open closed filed)

  def changeset(tax_year, attrs) do
    tax_year
    |> cast(attrs, [:year, :start_date, :end_date, :status, :organization_id])
    |> validate_required([:year, :start_date, :end_date, :organization_id])
    |> validate_inclusion(:status, @valid_statuses)
    |> unique_constraint([:year, :organization_id])
  end
end
