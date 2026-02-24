defmodule OpsPlatform.Finance.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :title, :string
    field :file_type, :string
    field :google_drive_id, :string
    field :category, :string
    field :uploaded_at, :utc_datetime

    belongs_to :transaction, OpsPlatform.Finance.Transaction
    belongs_to :tax_year, OpsPlatform.Finance.TaxYear
    belongs_to :organization, OpsPlatform.Accounts.Organization
    has_many :tax_documents, OpsPlatform.Finance.TaxDocument

    timestamps(type: :utc_datetime)
  end

  def changeset(document, attrs) do
    document
    |> cast(attrs, [
      :title,
      :file_type,
      :google_drive_id,
      :category,
      :uploaded_at,
      :transaction_id,
      :tax_year_id,
      :organization_id
    ])
    |> validate_required([:title, :organization_id])
  end
end
