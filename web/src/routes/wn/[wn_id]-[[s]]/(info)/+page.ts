import type { LoadEvent } from '@sveltejs/kit'
import { api_path, api_get } from '$lib/api_call'

interface BookUser {
  u_dname: string
  u_privi: number
  _status: string
}

export interface BookFront {
  books: CV.Wninfo[]
  users: BookUser[]
}

export const load = async ({ fetch, params }: LoadEvent) => {
  const api_url = `/_db/books/${params.wn_id}/front`

  const bdata = await api_get<BookFront>(api_url, fetch)
  const ydata = await load_ycrits(params.wn_id, fetch)

  return { bdata, ydata }
}

const load_ycrits = async (book: string, fetch = globalThis.fetch) => {
  const extra = { book, sort: 'score', lm: 3 }
  const ypath = api_path('yscrits.index', null, null, extra)
  const ydata = await api_get<CV.YscritList>(ypath, fetch)
  return ydata
}
