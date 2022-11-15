import { get_crits } from '$lib/ys_api'

async function load_crits(book_id: number, fetch = globalThis.fetch) {
  const opts = { book: book_id, take: 3, sort: 'score' }
  const { crits } = await get_crits(null, opts, fetch)
  return crits
}

export async function load({ fetch, parent }) {
  const { nvinfo } = await parent()

  const bhash = nvinfo.bslug.substring(0, 8)
  const api_url = `/api/books/${bhash}/front`

  const api_res = await fetch(api_url)
  const payload = await api_res.json()

  const crits = await load_crits(nvinfo.id, fetch)

  return { ...payload.props, crits }
}
