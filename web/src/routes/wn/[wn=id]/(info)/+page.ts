import type { LoadEvent } from '@sveltejs/kit'
import { api_get } from '$lib/api_call'

interface BookUser {
  uname: string
  privi: number
  umark: number
}

export interface BookFront {
  books: CV.Wninfo[]
  users: BookUser[]
}

export const load = async ({ url, fetch, params }: LoadEvent) => {
  const wn = parseInt(params.wn, 10)
  const gdroot = `wn:${wn}`

  const rppath = `/_db/droots/show/${gdroot}?lm=10`
  const { rplist } = await api_get<CV.GdrootPage>(rppath, fetch)

  const bdata = await api_get<BookFront>(`/_db/books/${wn}/front`, fetch)
  const ydata = await load_ycrits(wn, fetch)

  return { rplist, gdroot, bdata, ydata, ontab: 'fp' }
}

const load_ycrits = async (wn: number, fetch = globalThis.fetch) => {
  const path = `/_ys/crits?book=${wn}&sort=score&lm=3`
  return await api_get<CV.YscritList>(path, fetch)
}
