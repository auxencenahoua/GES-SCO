import { describe, expect, it } from "vitest";
import {
  assertPermission,
  assertTenantScope,
  ForbiddenError,
  type ActiveMembership,
} from "./permissions";

const tenantA: ActiveMembership = {
  userId: "user-a",
  tenantId: "11111111-1111-4111-8111-111111111111",
  status: "active",
  permissions: new Set(["students.read"]),
};

describe("tenant authorization", () => {
  it("rejects an access attempt to another establishment", () => {
    expect(() =>
      assertTenantScope(tenantA, "22222222-2222-4222-8222-222222222222"),
    ).toThrow(ForbiddenError);
  });

  it("rejects an ungranted permission", () => {
    expect(() => assertPermission(tenantA, "students.update")).toThrow(
      ForbiddenError,
    );
  });

  it("allows a granted permission in the active establishment", () => {
    expect(() => {
      assertTenantScope(tenantA, tenantA.tenantId);
      assertPermission(tenantA, "students.read");
    }).not.toThrow();
  });
});
