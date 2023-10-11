defmodule HTTPizza.Service do
  alias HTTPizza.Checks

  @spec validate_header_check(%Checks.HeaderCheck{}, Finch.Response.t()) :: %Checks.CheckResult{}
  def validate_header_check(%Checks.HeaderCheck{} = check, %Finch.Response{} = response) do
    kind = to_string(Checks.HeaderCheck)

    header = String.downcase(check.header)
    comparator = check.comparator
    expected = check.value

    received =
      Enum.find(response.headers, fn
        {^header, _} -> true
        _ -> false
      end)
      |> case do
        nil -> nil
        tuple -> elem(tuple, 1)
      end

    if header_value_match?(header, expected, received, comparator, check.case_sensitive) do
      %Checks.CheckResult{
        kind: kind,
        status: :ok,
        reason: "Received: #{received}"
      }
    else
      %Checks.CheckResult{
        kind: kind,
        status: :failed,
        reason: reason(comparator, expected, received)
      }
    end
  end

  @spec validate_header_check(%Checks.StatusCheck{}, Finch.Response.t()) :: %Checks.CheckResult{}
  def validate_status_check(%Checks.StatusCheck{} = check, %Finch.Response{} = response) do
    kind = to_string(Checks.StatusCheck)

    status =
      response.status
      |> to_string()

    match =
      case check.comparator do
        :equal_to -> check.code == status
        :is_success -> String.starts_with?(status, "2")
        :is_redirect -> String.starts_with?(status, "3")
      end

    if match do
      %Checks.CheckResult{
        kind: kind,
        status: :ok,
        reason: "Received #{status}"
      }
    else
      %Checks.CheckResult{
        kind: kind,
        status: :failed,
        reason: reason(check.comparator, check.code, status)
      }
    end
  end

  # in the context of the given header, do the `expected` and `received` string values
  # match when considering case sensitivity?
  def header_value_match?(_, _, nil, _, _), do: false

  def header_value_match?("location", expected_uri, received_uri, comparator, case_sensitive) do
    header_value_match?(
      "_location",
      String.replace_suffix(expected_uri, "/", ""),
      String.replace_suffix(received_uri, "/", ""),
      comparator,
      case_sensitive
    )
  end

  def header_value_match?(header, expected, received, comparator, false) do
    header_value_match?(
      header,
      String.downcase(expected),
      String.downcase(received),
      comparator,
      true
    )
  end

  def header_value_match?(_, _, nil, _, _), do: false

  def header_value_match?(_header, expected, received, comparator, true) do
    case comparator do
      :contains -> String.contains?(received, expected)
      :equal_to -> expected == received
      :starts_with -> String.starts_with?(received, expected)
      :ends_with -> String.ends_with?(received, expected)
      :does_not_contain -> not String.contains?(received, expected)
      :not_equal_to -> expected != received
    end
  end

  defp reason(_comparator, _expected, nil), do: "No matching header found"

  defp reason(comparator, expected, received) do
    expr =
      case comparator do
        :contains -> "to contain"
        :equal_to -> "to equal"
        :starts_with -> "to start with"
        :ends_with -> "to end with"
        :does_not_contain -> "to not contain"
        :not_equal_to -> "to not equal"
        :is_success -> "to be successful"
        :is_redirect -> "to be redirected"
      end

    String.trim("Expected #{received} #{expr} #{expected}")
  end
end
