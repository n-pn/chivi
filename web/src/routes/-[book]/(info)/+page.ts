import { get_crits } from '$lib/ys_api'
import { suggest_read } from '$utils/ubmemo_utils'

async function load_crits(book_id: number, fetch = globalThis.fetch) {
  const opts = { book: book_id, take: 3, sort: 'score' }
  const { crits } = await get_crits(null, opts, fetch)
  return crits
}

export async function load({ fetch, parent }) {
  const { nvinfo, ubmemo } = await parent()

  const bhash = nvinfo.bslug.substring(0, 8)
  const api_url = `/api/books/${bhash}/front`

  const api_res = await fetch(api_url)
  const payload = await api_res.json()

  const crits = await load_crits(nvinfo.id, fetch)

  const _meta: App.PageMeta = {
    title: `${nvinfo.btitle_vi}`,
    left_nav: [
      // prettier-ignore
      { text: nvinfo.btitle_vi, icon: 'book', href: `/-${nvinfo.bslug}`, "data-show": 'tm', "data-kind": 'title' },
    ],
    right_nav: [suggest_read(nvinfo, ubmemo)],
  }

  return { ...payload.props, crits, _meta }
}
