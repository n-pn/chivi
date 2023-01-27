import { api_get, api_path } from '$lib/api_call'
import type { PageData } from './$types'

export const load = (async ({ fetch, url }) => {
  const extras = { lm: 10, labels: url.searchParams.get('lb') }

  const path = api_path('dtopics.index', null, url.searchParams, extras)
  const data = await api_get(path, null, fetch)

  data['_path'] = 'forum'
  return data
}) satisfies PageData
