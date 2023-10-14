defmodule HTTPizza.ServiceTest do
  use HTTPizza.DataCase

  alias HTTPizza.Checks.HeaderCheck

  describe "validate_header_check/2" do
    test "returns failed CheckResult with no matching header" do
      header_check =
        %HeaderCheck{
          header: "Content-Type",
          comparator: :equal_to,
          value: "application/json",
          case_sensitive: true
        }

      changeset =
        HTTPizza.Service.validate_header_check(header_check, %Finch.Response{
          headers: []
        })

      assert Ecto.Changeset.get_field(changeset, :status) == :failed
    end

    test "returns successful CheckResult with matching header" do
      header_check =
        %HeaderCheck{
          header: "Accept",
          comparator: :equal_to,
          value: "application/json",
          case_sensitive: true
        }

      changeset =
        HTTPizza.Service.validate_header_check(header_check, %Finch.Response{
          headers: [{"accept", "application/json"}]
        })

      assert Ecto.Changeset.get_field(changeset, :status) == :ok
    end

    test "isn't picky with empty path" do
      header_check =
        %HeaderCheck{
          header: "Location",
          comparator: :equal_to,
          value: "https://example.com/",
          case_sensitive: true
        }

      changeset =
        HTTPizza.Service.validate_header_check(header_check, %Finch.Response{
          headers: [{"location", "https://example.com/"}]
        })

      assert Ecto.Changeset.get_field(changeset, :status) == :ok
    end

    test "returns failed CheckResult without matching header" do
      header_check =
        %HeaderCheck{
          header: "Location",
          comparator: :equal_to,
          value: "https://example.com/",
          case_sensitive: true
        }

      changeset =
        HTTPizza.Service.validate_header_check(header_check, %Finch.Response{
          headers: [{"location", "https://janeroe.org/"}]
        })

      assert Ecto.Changeset.get_field(changeset, :status) == :failed
    end

    test "returns successful CheckResult with case insensitive match" do
      header_check =
        %HeaderCheck{
          header: "X-Request-ID",
          comparator: :equal_to,
          value: "ABC123",
          case_sensitive: false
        }

      changeset =
        HTTPizza.Service.validate_header_check(header_check, %Finch.Response{
          headers: [{"x-request-id", "abc123"}]
        })

      assert Ecto.Changeset.get_field(changeset, :status) == :ok
    end

    test "returns failed CheckResult with case sensitive mismatch" do
      header =
        %HeaderCheck{
          header: "X-Request-ID",
          comparator: :equal_to,
          value: "ABC123",
          case_sensitive: true
        }

      changeset =
        HTTPizza.Service.validate_header_check(header, %Finch.Response{
          headers: [{"x-request-id", "abc123"}]
        })

      assert Ecto.Changeset.get_field(changeset, :status) == :failed
    end
  end
end
