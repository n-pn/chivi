import { api_get } from '$lib/api_call'
import type { LayoutLoad } from './$types'

export interface StemData {
  ustem: CV.Upstem
  chaps: CV.Wnchap[]
}

export const load = (async ({ fetch, params }) => {
  const sname = params.sn
  const up_id = +params.id
  const sroot = `/up/${sname}:${up_id}`

  const { ustem, chaps } = await api_get<StemData>(`/_up/stems/${up_id}`, fetch)
  return { ustem, lasts: chaps, sname, up_id, sroot }
}) satisfies LayoutLoad
