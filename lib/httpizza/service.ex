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
      |> elem(1)

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

  # in the context of the given header, do the `expected` and `received` string values
  # match when considering case sensitivity?
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

  defp reason(comparator, expected, received) do
    expr =
      case comparator do
        :contains -> "to contain"
        :equal_to -> "to equal"
        :starts_with -> "to start with"
        :ends_with -> "to end with"
        :does_not_contain -> "to not contain"
        :not_equal_to -> "to not equal"
      end

    "Expected #{received} #{expr} #{expected}"
  end
end
