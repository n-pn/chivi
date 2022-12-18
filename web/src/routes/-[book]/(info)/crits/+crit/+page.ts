import { set_fetch, api_get, api_path } from '$lib/api_call'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, url }) => {
  const id = url.searchParams.get('id')
  if (!id) return { form: undefined }

  set_fetch(fetch)
  const path = api_path('vicrits.edit', id)
  return { form: await api_get(path) }
}) satisfies PageLoad