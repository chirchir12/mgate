defmodule Mgate.Integrations.Mbanking do
  alias Mgate.Transfers.Transfer
  @headers [accept: "application/json", "content-type": "application/json"]

  def create(%Transfer{} = transfer, options \\ []) do
    url = options |> Keyword.get(:url)
    url = "#{url}/v1/payments/initiate"

    body =
      Jason.encode!(%{
        source: transfer.source,
        destination: transfer.destination,
        amount: Decimal.to_float(transfer.amount),
        transferType: transfer.transfer_type,
        transferId: transfer.uuid
      })

    case HTTPoison.post(url, body, @headers) do
      {:ok, %HTTPoison.Response{status_code: code} = res} -> handle_response(res, code)
      {:error, %HTTPoison.Error{} = error} -> handle_errors(error)
    end
  end

  def get_status(%Transfer{response_id: id}, options) do
    url = options |> Keyword.get(:url)
    url = "#{url}/v1/payments/status/#{id}"

    case HTTPoison.get(url, @headers) do
      {:ok, %HTTPoison.Response{status_code: code} = res} -> handle_response(res, code)
      {:error, %HTTPoison.Error{} = error} -> handle_errors(error)
    end
  end

  defp handle_response(%HTTPoison.Response{body: body}, 202) do
    {:ok, Jason.decode!(body)}
  end

  defp handle_response(%HTTPoison.Response{body: body}, 200) do
    {:ok, Jason.decode!(body)}
  end

  defp handle_response(%HTTPoison.Response{body: body}, 404) do
    {:error, Jason.decode!(body)}
  end

  defp handle_response(%HTTPoison.Response{body: body}, 400) do
    {:error, Jason.decode!(body)}
  end

  defp handle_response(%HTTPoison.Response{body: body}, 500) do
    {:error, Jason.decode!(body)}
  end

  defp handle_errors(%HTTPoison.Error{reason: reason}) do
    {:error, reason}
  end
end
