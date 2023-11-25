import { api_get } from '$lib/api_call'
import { writable } from 'svelte/store'
import type { LayoutLoad } from './$types'

interface UpstemShow {
  ustem: CV.Upstem
  crepo: CV.Chrepo
  rmemo: CV.Rdmemo
}

export const load = (async ({ fetch, params, depends }) => {
  const sname = params.sn
  const up_id = +params.id

  const sroot = `/up/${sname}:${up_id}`
  depends(sroot)

  const rdurl = `/_rd/upstems/${up_id}`
  const { ustem, rmemo, crepo } = await api_get<UpstemShow>(rdurl, fetch)

  let binfo: CV.Wninfo

  if (ustem.wn_id) {
    const bpath = `/_db/books/${ustem.wn_id}/show`
    binfo = await api_get<CV.Wninfo>(bpath, fetch)
  }

  rmemo.vname = ustem.vname
  rmemo.rpath = sroot

  return { ustem, crepo, rmemo: writable(rmemo), binfo, sname, up_id, sroot }
}) satisfies LayoutLoad
