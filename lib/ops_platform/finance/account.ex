defmodule OpsPlatform.Finance.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :name, :string
    field :type, :string
    field :external_id, :string
    field :last_sync_at, :utc_datetime

    belongs_to :organization, OpsPlatform.Accounts.Organization
    has_many :transactions, OpsPlatform.Finance.Transaction

    timestamps(type: :utc_datetime)
  end

  @valid_types ~w(checking savings credit)

  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :type, :external_id, :last_sync_at, :organization_id])
    |> validate_required([:name, :type, :organization_id])
    |> validate_inclusion(:type, @valid_types)
    |> unique_constraint(:external_id)
  end
end
