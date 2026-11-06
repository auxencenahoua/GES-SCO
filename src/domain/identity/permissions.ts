export const permissions = [
  "tenants.read",
  "settings.manage",
  "users.invite",
  "students.read",
  "students.create",
  "students.update",
  "students.archive",
  "grades.publish",
  "finance.payment.create",
  "finance.refund.approve",
  "audit.read",
] as const;

export type Permission = (typeof permissions)[number];

export type ActiveMembership = {
  userId: string;
  tenantId: string;
  status: "active";
  permissions: ReadonlySet<Permission>;
};

export function assertTenantScope(
  membership: ActiveMembership,
  tenantId: string,
): void {
  if (membership.tenantId !== tenantId) {
    throw new ForbiddenError("Accès refusé : établissement non autorisé.");
  }
}

export function assertPermission(
  membership: ActiveMembership,
  permission: Permission,
): void {
  if (!membership.permissions.has(permission)) {
    throw new ForbiddenError("Accès refusé : permission insuffisante.");
  }
}

export class ForbiddenError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ForbiddenError";
  }
}
