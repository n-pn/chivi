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
  const gdroot = `wn:${parseInt(params.wn, 10)}`

  const sort = url.searchParams.get('sort') || '-id'
  const path = `/_db/droots/show/${gdroot}?sort=${sort}&lm=9999`

  const { rplist } = await api_get<CV.GdrootPage>(path, fetch)

  return { rplist, gdroot, sort, ontab: 'fp' }
}
