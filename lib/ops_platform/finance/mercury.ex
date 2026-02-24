defmodule OpsPlatform.Finance.Mercury do
  @moduledoc """
  Mercury Bank API client for syncing accounts and transactions.
  Uses Req for HTTP requests.
  """

  @base_url "https://api.mercury.com/api/v1"

  defp api_token do
    Application.get_env(:ops_platform, __MODULE__)[:api_token] ||
      raise "Mercury API token not configured"
  end

  defp client do
    Req.new(
      base_url: @base_url,
      headers: [
        {"authorization", "Bearer #{api_token()}"},
        {"accept", "application/json"}
      ]
    )
  end

  def list_accounts do
    case Req.get(client(), url: "/accounts") do
      {:ok, %Req.Response{status: 200, body: %{"accounts" => accounts}}} ->
        {:ok, accounts}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def list_transactions(account_id, opts \\ []) do
    params =
      opts
      |> Keyword.take([:offset, :limit, :start, :end, :status])
      |> Enum.into(%{})

    case Req.get(client(), url: "/account/#{account_id}/transactions", params: params) do
      {:ok, %Req.Response{status: 200, body: %{"transactions" => transactions}}} ->
        {:ok, transactions}

      {:ok, %Req.Response{status: 200, body: body}} when is_list(body) ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def sync_accounts(organization_id) do
    case list_accounts() do
      {:ok, mercury_accounts} ->
        results = Enum.map(mercury_accounts, &sync_account(&1, organization_id))
        {:ok, results}

      error ->
        error
    end
  end

  defp sync_account(mercury_account, organization_id) do
    attrs = %{
      name: mercury_account["name"] || mercury_account["nickname"],
      type: normalize_account_type(mercury_account["type"]),
      external_id: mercury_account["id"],
      organization_id: organization_id,
      last_sync_at: DateTime.utc_now()
    }

    case OpsPlatform.Finance.get_account_by_external_id(mercury_account["id"]) do
      nil -> OpsPlatform.Finance.create_account(attrs)
      existing -> OpsPlatform.Finance.update_account(existing, attrs)
    end
  end

  def sync_transactions(account_id, opts \\ []) do
    account = OpsPlatform.Finance.get_account!(account_id)

    with {:ok, mercury_transactions} <- list_transactions(account.external_id, opts) do
      results =
        Enum.map(mercury_transactions, fn mt ->
          attrs = %{
            external_id: mt["id"],
            date: parse_date(mt["postedAt"] || mt["createdAt"]),
            amount: mt["amount"] |> abs() |> Decimal.new(),
            description: mt["note"] || mt["bankDescription"],
            counterparty: get_in(mt, ["counterpartyName"]) || mt["counterpartyName"],
            kind: if(mt["amount"] >= 0, do: "income", else: "expense"),
            status: "pending",
            metadata: mt,
            account_id: account.id
          }

          OpsPlatform.Finance.upsert_transaction(attrs)
        end)

      OpsPlatform.Finance.update_account(account, %{last_sync_at: DateTime.utc_now()})
      {:ok, results}
    end
  end

  defp normalize_account_type(type) when is_binary(type) do
    case String.downcase(type) do
      "checking" -> "checking"
      "savings" -> "savings"
      "credit" -> "credit"
      _ -> "checking"
    end
  end

  defp normalize_account_type(_), do: "checking"

  defp parse_date(nil), do: Date.utc_today()

  defp parse_date(date_string) when is_binary(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} ->
        date

      _ ->
        case DateTime.from_iso8601(date_string) do
          {:ok, datetime, _} -> DateTime.to_date(datetime)
          _ -> Date.utc_today()
        end
    end
  end
end
