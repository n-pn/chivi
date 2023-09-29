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

  let binfo: CV.Wninfo

  if (ustem.wninfo_id) {
    const bpath = `/_db/books/${ustem.wninfo_id}/show`
    binfo = await api_get<CV.Wninfo>(bpath, fetch)
  }

  return { ustem, binfo, lasts: chaps, sname, up_id, sroot }
}) satisfies LayoutLoad
