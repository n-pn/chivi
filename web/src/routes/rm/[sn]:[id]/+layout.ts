import { api_get } from '$lib/api_call'
import type { LayoutLoad } from './$types'

export const load = (async ({ fetch, params }) => {
  const sname = params.sn
  const sn_id = params.id
  const sroot = `/rm/${sname}:${sn_id}`

  const rdurl = `/_rd/rmstems/${sname}/${sn_id}`
  const rstem = await api_get<CV.Rmstem>(rdurl, fetch)

  let binfo: CV.Wninfo

  if (rstem.wn_id) {
    const bpath = `/_db/books/${rstem.wn_id}/show`
    binfo = await api_get<CV.Wninfo>(bpath, fetch)
  }

  return { rstem, binfo, sname, sn_id, sroot }
}) satisfies LayoutLoad
