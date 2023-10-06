defmodule HTTPizza.Service do
  alias HTTPizza.Checks

  @spec validate_http_check(%Checks.HTTPHeadCheck{}, Finch.Response.t()) :: %Checks.CheckResult{}
  def validate_http_check(%Checks.HTTPHeadCheck{} = check, %Finch.Response{} = response) do
    kind = to_string(Checks.HTTPHeadCheck)
    header = String.downcase(check.header)
    expected = check.value
    received = Enum.find(response.headers, fn {^header, _} -> true end) |> elem(1)

    if header_value_match?(header, expected, received, check.case_sensitive) do
      %Checks.CheckResult{
        status: :ok,
        reason: "Received: #{received}"
      }
    else
      %Checks.CheckResult{
        kind: kind,
        status: :failed,
        reason: "Expected: #{expected}; received: #{received}"
      }
    end
  end

  # in the context of the given header, do the `expected` and `received` string values
  # match when considering case sensitivity?
  @spec header_value_match?(String.t(), String.t(), String.t(), boolean()) :: boolean()
  def header_value_match?("location", expected_uri, received_uri, _case_sensitive) do
    default_path_uri(expected_uri) == default_path_uri(received_uri)
  end

  def header_value_match?(header, expected, received, false) do
    header_value_match?(header, String.downcase(expected), String.downcase(received), true)
  end

  def header_value_match?(_header, expected, received, true) do
    expected == received
  end

  @spec default_path_uri(String.t()) :: URI.t()
  defp default_path_uri(uri) do
    result = URI.new!(uri)

    if is_nil(result.path) do
      %{result | path: "/"}
    else
      result
    end
  end
end
