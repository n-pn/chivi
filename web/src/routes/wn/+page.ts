import { api_path, api_get } from '$lib/api_call'
import type { LoadEvent } from '@sveltejs/kit'

interface BookList extends CV.Paginate {
  books: CV.Nvinfo[]
}

export async function load({ url, fetch }: LoadEvent) {
  const path = api_path('wnovels.index', null, url.searchParams, { lm: 24 })
  const data = await api_get<BookList>(path, null, fetch)
  return data
}
