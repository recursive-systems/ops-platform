defmodule OpsPlatform.Finance.TaxTask do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tax_tasks" do
    field :title, :string
    field :description, :string
    field :due_date, :date
    field :status, :string, default: "pending"
    field :category, :string
    field :priority, :string, default: "medium"
    field :notes, :string

    belongs_to :tax_year, OpsPlatform.Finance.TaxYear

    timestamps(type: :utc_datetime)
  end

  @valid_statuses ~w(pending in_progress completed)
  @valid_priorities ~w(low medium high)

  def changeset(tax_task, attrs) do
    tax_task
    |> cast(attrs, [
      :title,
      :description,
      :due_date,
      :status,
      :category,
      :priority,
      :notes,
      :tax_year_id
    ])
    |> validate_required([:title, :tax_year_id])
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_inclusion(:priority, @valid_priorities)
  end
end
