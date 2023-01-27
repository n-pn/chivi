import type { LoadEvent } from '@sveltejs/kit'
import { api_path } from '$lib/api_call'

export const load = async ({ fetch, parent, url }: LoadEvent) => {
  const { nvinfo } = await parent()

  const sort = url.searchParams.get('sort') || 'score'
  const opts = { book: nvinfo.id, lm: 10, sort }
  const path = api_path('yslists.index', null, url.searchParams, opts)
  return fetch(path).then((r) => r.json())
}
