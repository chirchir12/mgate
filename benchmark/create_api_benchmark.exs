defmodule ApiBenchmark do
  @moduledoc """
  Module to benchmark API performance with 5000 requests.
  """
   @headers [accept: "application/json", "content-type": "application/json"]

  def run do
    url = "127.0.0.1:4000/api/transfers/execute" # Replace with your API endpoint
    requests = 5000

    IO.puts("Starting benchmark...")

    start_time = :os.system_time(:millisecond)
    responses = Enum.map(1..requests, fn _ -> make_request(url) end)
    end_time = :os.system_time(:millisecond)

    successful_requests = Enum.count(responses, &match?({:ok, _}, &1))
    failed_requests = requests - successful_requests

    IO.puts("Benchmark completed.")
    IO.puts("Total requests: #{requests}")
    IO.puts("Successful requests: #{successful_requests}")
    IO.puts("Failed requests: #{failed_requests}")
    IO.puts("Total time taken (ms): #{end_time - start_time}")
    IO.puts("Average time per request (ms): #{(end_time - start_time) / requests}")
  end

  defp make_request(url) do
    body =
      Jason.encode!(%{transfer: %{
        source: 123,
        destination: 321,
        amount: 10,
        transfer_type: "accountToAccount",
        uuid: Ecto.UUID.generate(),
        user_id: Ecto.UUID.generate(),
      }})
    case HTTPoison.post(url, body, @headers) do
      {:ok, response} -> {:ok, response.status_code}
      {:error, reason} -> {:error, reason}
    end
  end
end

ApiBenchmark.run()
