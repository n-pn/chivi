import { api_get } from '$lib/api_call'
import { writable } from 'svelte/store'
import type { LayoutLoad } from './$types'

interface RmstemShow {
  rstem: CV.Rmstem
  crepo: CV.Chrepo
  rmemo: CV.Rdmemo
}

export const load = (async ({ fetch, params, depends }) => {
  const sname = params.sn
  const sn_id = params.id

  const sroot = `/rm/${sname}:${sn_id}`
  depends(sroot)

  const rdurl = `/_rd/rmstems/${sname}/${sn_id}`
  const { rstem, crepo, rmemo } = await api_get<RmstemShow>(rdurl, fetch)

  let binfo: CV.Wninfo

  if (rstem.wn_id) {
    const bpath = `/_db/books/${rstem.wn_id}/show`
    binfo = await api_get<CV.Wninfo>(bpath, fetch)
  }

  return { rstem, crepo, rmemo: writable(rmemo), binfo, sname, sn_id, sroot }
}) satisfies LayoutLoad
