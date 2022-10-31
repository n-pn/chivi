import { get_crits } from '$lib/ys_api'

throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ fetch, stuff, url }) {
  const sort = url.searchParams.get('sort') || 'score'
  const opts = { book: stuff.nvinfo.id, take: 10, sort }
  const props = await get_crits(url.searchParams, opts, fetch)

  return props
}
