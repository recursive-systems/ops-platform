defmodule OpsPlatform.Finance.TaxDocument do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tax_documents" do
    field :document_type, :string
    field :issuer, :string
    field :amount, :decimal
    field :received_at, :date
    field :notes, :string

    belongs_to :tax_year, OpsPlatform.Finance.TaxYear
    belongs_to :document, OpsPlatform.Finance.Document

    timestamps(type: :utc_datetime)
  end

  @valid_types ~w(W2 1099-NEC 1099-MISC 1099-INT 1099-DIV 1099-K K1 other)

  def changeset(tax_document, attrs) do
    tax_document
    |> cast(attrs, [
      :document_type,
      :issuer,
      :amount,
      :received_at,
      :notes,
      :tax_year_id,
      :document_id
    ])
    |> validate_required([:document_type, :tax_year_id])
    |> validate_inclusion(:document_type, @valid_types)
  end
end
