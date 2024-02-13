import type { LoadEvent } from '@sveltejs/kit'
import { api_get } from '$lib/api_call'

interface BookUser {
  uname: string
  privi: number
  track: number
  ch_no: number
}

export interface BookFront {
  books: CV.Wninfo[]
  users: BookUser[]
}

export const load = async ({ fetch, params }: LoadEvent) => {
  const wn = parseInt(params.wn, 10)

  const bdata = await api_get<BookFront>(`/_db/books/${wn}/front`, fetch)
  const ydata = await load_ycrits(wn, fetch)

  return { bdata, ydata, ontab: '' }
}

const load_ycrits = async (wn: number, fetch = globalThis.fetch) => {
  const path = `/_ys/crits?wn=${wn}&_s=score&lm=3`
  return await api_get<CV.YscritList>(path, fetch)
}
