import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  dicts: CV.Zvdict[]
}

export const load = (async ({ fetch, url }) => {
  const kind = url.searchParams.get('kind') || ''
  const path = `/_sp/dicts${url.search || '?pg=1'}&lm=30`
  const data = await api_get<JsonData>(path, fetch)
  return { ...data, kind, ontab: kind || 'cv' }
}) satisfies PageLoad
