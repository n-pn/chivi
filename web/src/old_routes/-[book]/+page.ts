import { page } from '$app/stores'
import { get_crits } from '$lib/ys_api'

import { status_icons, status_names, status_colors } from '$lib/constants'

throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ fetch, stuff }) {
  const bhash = stuff.nvinfo.bslug.substring(0, 8)
  const api_url = `/api/books/${bhash}/front`

  const api_res = await fetch(api_url)
  const payload = await api_res.json()

  payload.props.crits = await load_crits(stuff.nvinfo.id, fetch)
  payload.props.nvinfo = stuff.nvinfo
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return payload
}

async function load_crits(book_id: number, fetch = globalThis.fetch) {
  const opts = { book: book_id, take: 3, sort: 'score' }
  const { crits } = await get_crits(null, opts, fetch)
  return crits
}
