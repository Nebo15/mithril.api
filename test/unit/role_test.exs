defmodule Mithril.RoleAPI.RoleTest do
  use ExUnit.Case

  test "Owner role" do
    role = %Mithril.RoleAPI.Role{
      name: "Owner",
      scope: "
        legal_entity:read
        employee_request:read
        employee_request:write
        employee_request:approve
        employee_request:reject
        employee:read
        employee:write
      "
    }

    assert String.contains?(role.scope, "legal_entity:read")
    assert String.contains?(role.scope, "employee_request:read")
    assert String.contains?(role.scope, "employee_request:write")
    assert String.contains?(role.scope, "employee_request:approve")
    assert String.contains?(role.scope, "employee_request:reject")
    assert String.contains?(role.scope, "employee:read")
    assert String.contains?(role.scope, "employee:write")
  end

  test "Doctor role" do
    role = %Mithril.RoleAPI.Role{
      name: "Doctor",
      scope: "
        legal_entity:read
        employee_request:read
        employee_request:approve
        employee_request:reject
        employee:read
      "
    }

    assert String.contains?(role.scope, "legal_entity:read")
    assert String.contains?(role.scope, "employee_request:read")
    assert String.contains?(role.scope, "employee_request:approve")
    assert String.contains?(role.scope, "employee_request:reject")
    assert String.contains?(role.scope, "employee:read")
  end
end
