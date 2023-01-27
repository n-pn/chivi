import { api_get } from '$lib/api_call'
import type { LoadEvent } from '@sveltejs/kit'

interface BookList {
  recent: CV.Nvinfo[]
  update: CV.Nvinfo[]
  weight: CV.Nvinfo[]
}

export const load = async ({ fetch }: LoadEvent) => {
  // const ydata = await fetch('/_ys/front').then((r) => r.json())
  return {
    books: await api_get<BookList>('/_db/ranks/brief', null, fetch),
  }
}
