import { api_path, api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface CritData {
  entry: CV.Yscrit
  vbook: CV.Crbook
  repls: CV.YsRepl[]
}

export const load = (async ({ fetch, params: { crit } }) => {
  const path = api_path('yscrits.show', crit)
  return await api_get<CritData>(path, fetch)
}) satisfies PageLoad
