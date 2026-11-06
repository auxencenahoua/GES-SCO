import type { PoolClient, QueryResultRow } from "pg";

export type PageRequest = { page?: number; pageSize?: number };
export function normalisePage({ page = 1, pageSize = 25 }: PageRequest) {
  return {
    page: Math.max(1, Math.floor(page)),
    pageSize: Math.min(100, Math.max(1, Math.floor(pageSize))),
  };
}
export async function queryPage<T extends QueryResultRow>(
  client: PoolClient,
  query: string,
  values: readonly unknown[],
  request: PageRequest,
) {
  const { page, pageSize } = normalisePage(request);
  const result = await client.query<T>(
    `${query} LIMIT $${values.length + 1} OFFSET $${values.length + 2}`,
    [...values, pageSize, (page - 1) * pageSize],
  );
  return {
    items: result.rows,
    page,
    pageSize,
    hasNextPage: result.rows.length === pageSize,
  };
}
