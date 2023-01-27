import type { LoadEvent } from '@sveltejs/kit'
import { api_path, api_get, set_fetch } from '$lib/api_call'

interface BookUser {
  u_dname: string
  u_privi: number
  _status: string
}
export interface BookFront {
  books: CV.Nvinfo[]
  users: BookUser[]
}

export const load = async ({ fetch, params }: LoadEvent) => {
  const wn_id = params.bname.split('-')[0]
  const api_url = `/_db/v2/books/${wn_id}/front`

  const bdata = await api_get<BookFront>(api_url, null, fetch)
  const crits = await load_ycrits(wn_id, fetch)

  return { ...bdata, crits }
}

const load_ycrits = async (book: string, fetch = globalThis.fetch) => {
  const extra = { book, sort: 'score', lm: 3 }
  const ypath = api_path('yscrits.index', null, null, extra)
  const ydata = await api_get<{ crits: CV.Yscrit[] }>(ypath, null, fetch)
  return ydata.crits
}
