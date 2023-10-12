import { api_get } from '$lib/api_call'
import type { LayoutLoad } from './$types'

export const load = (async ({ fetch, params, depends }) => {
  const sname = params.sn
  const up_id = +params.id

  const sroot = `/up/${sname}:${up_id}`
  depends(sroot)

  const ustem = await api_get<CV.Upstem>(`/_rd/upstems/${up_id}`, fetch)

  const rstem = `up${sname}/${up_id}`
  const rmemo = await api_get<CV.Rdmemo>(`/_rd/rdmemos/${rstem}`, fetch)

  let binfo: CV.Wninfo

  if (ustem.wn_id) {
    const bpath = `/_db/books/${ustem.wn_id}/show`
    binfo = await api_get<CV.Wninfo>(bpath, fetch)
  }

  return { ustem, rmemo, binfo, sname, up_id, sroot }
}) satisfies LayoutLoad
