import { api_get } from '$lib/api_call'

import type { LayoutLoad } from './$types'

export interface DictData {
  dinfo: CV.Zvdict
  users: string[]
  // terms: CV.Viterm[]
}

export const load = (async ({ fetch, params: { name } }) => {
  return await api_get<DictData>(`/_sp/dicts/${name}_pair`, fetch)
}) satisfies LayoutLoad
