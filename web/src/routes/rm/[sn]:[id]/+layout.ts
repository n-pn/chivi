import { api_get } from '$lib/api_call'
import type { LayoutLoad } from './$types'

export interface Data {
  rstem: CV.Rmstem
  lasts: CV.Wnchap[]
}

export const load = (async ({ fetch, params }) => {
  const sname = params.sn
  const up_id = +params.id
  const sroot = `/rm/${sname}:${up_id}`

  const url = `/_rd/rmstems/${up_id}`
  const { rstem, lasts } = await api_get<Data>(url, fetch)

  let binfo: CV.Wninfo

  if (rstem.wn_id) {
    const bpath = `/_db/books/${rstem.wn_id}/show`
    binfo = await api_get<CV.Wninfo>(bpath, fetch)
  }

  return { rstem, binfo, lasts, sname, up_id, sroot }
}) satisfies LayoutLoad
