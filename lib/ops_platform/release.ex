defmodule OpsPlatform.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :ops_platform

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def seed do
    load_app()

    alias OpsPlatform.Repo
    alias OpsPlatform.Accounts.{Organization, User}
    alias OpsPlatform.Finance.{Category, TaxYear}

    # Create default organization
    org =
      Repo.insert!(%Organization{
        name: "Recursive Systems",
        slug: "recursive-systems",
        settings: %{}
      })

    # Create admin user (password: "password123")
    Repo.insert!(%User{
      email: "admin@recursive.systems",
      name: "Admin User",
      hashed_password: Bcrypt.hash_pwd_salt("password123"),
      organization_id: org.id
    })

    # Create default categories
    categories = [
      %{name: "Advertising", schedule_c_line: "8", tax_deductible: true},
      %{name: "Car & Truck Expenses", schedule_c_line: "9", tax_deductible: true},
      %{name: "Commissions & Fees", schedule_c_line: "10", tax_deductible: true},
      %{name: "Contract Labor", schedule_c_line: "11", tax_deductible: true},
      %{name: "Insurance", schedule_c_line: "15", tax_deductible: true},
      %{name: "Legal & Professional", schedule_c_line: "17", tax_deductible: true},
      %{name: "Office Expense", schedule_c_line: "18", tax_deductible: true},
      %{name: "Rent or Lease", schedule_c_line: "20b", tax_deductible: true},
      %{name: "Supplies", schedule_c_line: "22", tax_deductible: true},
      %{name: "Travel", schedule_c_line: "24a", tax_deductible: true},
      %{name: "Meals", schedule_c_line: "24b", tax_deductible: true},
      %{name: "Utilities", schedule_c_line: "25", tax_deductible: true},
      %{name: "Software & SaaS", schedule_c_line: "27a", tax_deductible: true},
      %{name: "Income", schedule_c_line: "1", tax_deductible: false},
      %{name: "Transfer", schedule_c_line: nil, tax_deductible: false},
      %{name: "Personal", schedule_c_line: nil, tax_deductible: false}
    ]

    for cat <- categories do
      Repo.insert!(%Category{
        name: cat.name,
        schedule_c_line: cat.schedule_c_line,
        tax_deductible: cat.tax_deductible,
        organization_id: org.id
      })
    end

    # Create current tax year
    Repo.insert!(%TaxYear{
      year: 2025,
      start_date: ~D[2025-01-01],
      end_date: ~D[2025-12-31],
      status: "open",
      organization_id: org.id
    })

    IO.puts("✅ Seeds completed successfully!")
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.ensure_all_started(:ssl)
    Application.ensure_all_started(@app)
  end
end
