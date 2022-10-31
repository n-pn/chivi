import { wrap_get } from '$lib/api_call'

throw new Error("@migration task: Check if you need to migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ fetch, url, params: { author } }) {
  const page = +url.searchParams.get('pg') || 1
  const api_url = `/api/books?order=weight&lm=8&pg=${page}&author=${author}`

  const topbar = { left: [[author, 'edit', { href: `/books/=${author}` }]] }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return await wrap_get(fetch, api_url, null, { author }, { topbar })
}
