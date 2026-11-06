/** Stores money in minor units; never use floating point for financial values. */
export function formatXof(
  amountInMinorUnits: number,
  locale = "fr-CI",
): string {
  if (!Number.isSafeInteger(amountInMinorUnits)) {
    throw new TypeError(
      "Le montant doit être un entier sûr en unités mineures.",
    );
  }

  return new Intl.NumberFormat(locale, {
    style: "currency",
    currency: "XOF",
    maximumFractionDigits: 0,
  }).format(amountInMinorUnits);
}
