defmodule HTTPizza.ServiceTest do
  use HTTPizza.DataCase

  describe "validate_http_check/2" do
    import HTTPizza.ChecksFixtures

    test "returns successful CheckResult with matching header" do
      http_head_check =
        http_head_check_fixture(%{
          header: "Accept",
          value: "application/json"
        })

      result =
        HTTPizza.Service.validate_http_check(http_head_check, %Finch.Response{
          headers: [{"accept", "application/json"}]
        })

      assert result.status == :ok
    end

    test "isn't picky with empty path" do
      http_head_check =
        http_head_check_fixture(%{
          header: "Location",
          value: "https://example.com"
        })

      result =
        HTTPizza.Service.validate_http_check(http_head_check, %Finch.Response{
          headers: [{"location", "https://example.com/"}]
        })

      assert result.status == :ok
    end

    test "returns failed CheckResult without matching header" do
      http_head_check =
        http_head_check_fixture(%{
          header: "Location",
          value: "https://example.com/"
        })

      result =
        HTTPizza.Service.validate_http_check(http_head_check, %Finch.Response{
          headers: [{"location", "https://janeroe.org/"}]
        })

      assert result.status == :failed
    end

    test "returns successful CheckResult with case insensitive match" do
      http_head_check =
        http_head_check_fixture(%{
          header: "X-Request-ID",
          value: "ABC123",
          case_sensitive: false
        })

      result =
        HTTPizza.Service.validate_http_check(http_head_check, %Finch.Response{
          headers: [{"x-request-id", "abc123"}]
        })

      assert result.status == :ok
    end

    test "returns failed CheckResult with case sensitive mismatch" do
      http_head_check =
        http_head_check_fixture(%{
          header: "X-Request-ID",
          value: "ABC123",
          case_sensitive: true
        })

      result =
        HTTPizza.Service.validate_http_check(http_head_check, %Finch.Response{
          headers: [{"x-request-id", "abc123"}]
        })

      assert result.status == :failed
    end
  end
end
