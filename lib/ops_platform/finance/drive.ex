defmodule OpsPlatform.Finance.Drive do
  @moduledoc """
  Google Drive integration for document upload and management.
  Uses Req for HTTP requests with OAuth2 bearer token.
  """

  @upload_url "https://www.googleapis.com/upload/drive/v3/files"

  defp access_token do
    Application.get_env(:ops_platform, __MODULE__)[:access_token] ||
      raise "Google Drive access token not configured"
  end

  defp folder_id do
    Application.get_env(:ops_platform, __MODULE__)[:folder_id]
  end

  def upload_document(file_path, title, mime_type \\ "application/pdf") do
    metadata =
      %{name: title, mimeType: mime_type}
      |> then(fn meta ->
        case folder_id() do
          nil -> meta
          id -> Map.put(meta, :parents, [id])
        end
      end)

    file_content = File.read!(file_path)

    boundary = "ops_platform_boundary_#{System.unique_integer([:positive])}"

    body =
      "--#{boundary}\r\n" <>
        "Content-Type: application/json; charset=UTF-8\r\n\r\n" <>
        Jason.encode!(metadata) <>
        "\r\n--#{boundary}\r\n" <>
        "Content-Type: #{mime_type}\r\n\r\n" <>
        file_content <>
        "\r\n--#{boundary}--"

    case Req.post(
           Req.new(
             url: "#{@upload_url}?uploadType=multipart",
             headers: [
               {"authorization", "Bearer #{access_token()}"},
               {"content-type", "multipart/related; boundary=#{boundary}"}
             ],
             body: body
           )
         ) do
      {:ok, %Req.Response{status: 200, body: %{"id" => file_id}}} ->
        {:ok, file_id}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
