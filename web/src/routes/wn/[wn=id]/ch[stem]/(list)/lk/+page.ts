import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params: { wn, stem } }) => {
  const wn_id = parseInt(wn, 10)

  const up_api = `/_up/stems?wn=${wn_id}`
  const { items: ustems } = await api_get<{ items: CV.Upstem }>(up_api, fetch)

  return { ustems, ontab: 'lk' }
}) satisfies PageLoad
