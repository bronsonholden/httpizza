defmodule HTTPizza.ChecksTest do
  use HTTPizza.DataCase

  alias HTTPizza.Checks

  describe "http_status_checks" do
    alias HTTPizza.Checks.HTTPStatusCheck

    import HTTPizza.ChecksFixtures

    @invalid_attrs %{code: nil, comparator: nil}

    test "list_http_status_checks/0 returns all http_status_checks" do
      http_status_check = http_status_check_fixture()
      assert Checks.list_http_status_checks() == [http_status_check]
    end

    test "get_http_status_check!/1 returns the http_status_check with given id" do
      http_status_check = http_status_check_fixture()
      assert Checks.get_http_status_check!(http_status_check.id) == http_status_check
    end

    test "create_http_status_check/1 with valid data creates a http_status_check" do
      valid_attrs = %{code: "200", comparator: :is_exactly}

      assert {:ok, %HTTPStatusCheck{} = http_status_check} =
               Checks.create_http_status_check(valid_attrs)

      assert http_status_check.code == "200"
      assert http_status_check.comparator == :is_exactly
    end

    test "create_http_status_check/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Checks.create_http_status_check(@invalid_attrs)
    end

    test "create_http_status_check/1 with missing code and is exactly comparator returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Checks.create_http_status_check(%{comparator: :is_exactly, code: nil})
    end

    test "update_http_status_check/2 with valid data updates the http_status_check" do
      http_status_check = http_status_check_fixture()
      update_attrs = %{code: "some updated code", comparator: :is_success}

      assert {:ok, %HTTPStatusCheck{} = http_status_check} =
               Checks.update_http_status_check(http_status_check, update_attrs)

      assert http_status_check.code == "some updated code"
      assert http_status_check.comparator == :is_success
    end

    test "update_http_status_check/2 with invalid data returns error changeset" do
      http_status_check = http_status_check_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Checks.update_http_status_check(http_status_check, @invalid_attrs)

      assert http_status_check == Checks.get_http_status_check!(http_status_check.id)
    end

    test "update_http_status_check/2 with missing code and is exactly comparator returns error changeset" do
      http_status_check = http_status_check_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Checks.update_http_status_check(http_status_check, %{
                 comparator: :is_exactly,
                 code: nil
               })

      assert http_status_check == Checks.get_http_status_check!(http_status_check.id)
    end

    test "delete_http_status_check/1 deletes the http_status_check" do
      http_status_check = http_status_check_fixture()
      assert {:ok, %HTTPStatusCheck{}} = Checks.delete_http_status_check(http_status_check)

      assert_raise Ecto.NoResultsError, fn ->
        Checks.get_http_status_check!(http_status_check.id)
      end
    end

    test "change_http_status_check/1 returns a http_status_check changeset" do
      http_status_check = http_status_check_fixture()
      assert %Ecto.Changeset{} = Checks.change_http_status_check(http_status_check)
    end
  end
end
