import { type NextRequest } from "next/server";

import { Client } from "pg";

export const dynamic = "force-dynamic"; // defaults to auto

// TODO: connection pooling (either here, or in pgbouncer)
export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const page = parseInt(searchParams.get("page") ?? "1");
  const perPage = parseInt(searchParams.get("per_page") ?? "10");

  // page is 1-indexed
  const offset = (page - 1) * perPage;
  console.log(page, offset, perPage);

  const client = new Client();
  await client.connect();
  const res = await client.query(
    `
    SELECT quote_id, name, text FROM quotes JOIN authors USING (author_id)
    ORDER BY name ASC, quote_id ASC
    LIMIT $1
    OFFSET $2;
  `,
    [perPage, offset]
  );
  await client.end();

  return Response.json(res.rows);
}
