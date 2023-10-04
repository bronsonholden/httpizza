defmodule HTTPizza.ChecksTest do
  use HTTPizza.DataCase

  alias HTTPizza.Checks

  describe "http_head_checks" do
    alias HTTPizza.Checks.HTTPHeadCheck

    import HTTPizza.ChecksFixtures

    @invalid_attrs %{value: nil, header: nil, comparator: nil}

    test "list_http_head_checks/0 returns all http_head_checks" do
      http_head_check = http_head_check_fixture()
      assert Checks.list_http_head_checks() == [http_head_check]
    end

    test "get_http_head_check!/1 returns the http_head_check with given id" do
      http_head_check = http_head_check_fixture()
      assert Checks.get_http_head_check!(http_head_check.id) == http_head_check
    end

    test "create_http_head_check/1 with valid data creates a http_head_check" do
      valid_attrs = %{value: "some value", header: "some header", comparator: :contains}

      assert {:ok, %HTTPHeadCheck{} = http_head_check} =
               Checks.create_http_head_check(valid_attrs)

      assert http_head_check.value == "some value"
      assert http_head_check.header == "some header"
      assert http_head_check.comparator == :contains
    end

    test "create_http_head_check/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Checks.create_http_head_check(@invalid_attrs)
    end

    test "update_http_head_check/2 with valid data updates the http_head_check" do
      http_head_check = http_head_check_fixture()

      update_attrs = %{
        value: "some updated value",
        header: "some updated header",
        comparator: :equal_to
      }

      assert {:ok, %HTTPHeadCheck{} = http_head_check} =
               Checks.update_http_head_check(http_head_check, update_attrs)

      assert http_head_check.value == "some updated value"
      assert http_head_check.header == "some updated header"
      assert http_head_check.comparator == :equal_to
    end

    test "update_http_head_check/2 with invalid data returns error changeset" do
      http_head_check = http_head_check_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Checks.update_http_head_check(http_head_check, @invalid_attrs)

      assert http_head_check == Checks.get_http_head_check!(http_head_check.id)
    end

    test "delete_http_head_check/1 deletes the http_head_check" do
      http_head_check = http_head_check_fixture()
      assert {:ok, %HTTPHeadCheck{}} = Checks.delete_http_head_check(http_head_check)
      assert_raise Ecto.NoResultsError, fn -> Checks.get_http_head_check!(http_head_check.id) end
    end

    test "change_http_head_check/1 returns a http_head_check changeset" do
      http_head_check = http_head_check_fixture()
      assert %Ecto.Changeset{} = Checks.change_http_head_check(http_head_check)
    end
  end
end
