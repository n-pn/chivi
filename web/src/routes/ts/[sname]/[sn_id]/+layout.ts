import { api_get } from '$lib/api_call'
import { writable } from 'svelte/store'
import type { LayoutLoad } from './$types'
import { home_nav, nav_link } from '$utils/header_util'

interface LayoutData {
  crepo: CV.Tsrepo
  rmemo: CV.Rdmemo
  xstem: CV.Upstem | CV.Wnstem | CV.Rmstem
}

export const load = (async ({ fetch, params }) => {
  const sname = params.sname
  const sn_id = parseInt(params.sn_id)

  const tsurl = `/_rd/tsrepos/${sname}/${sn_id}`
  const { crepo, rmemo, xstem } = await api_get<LayoutData>(tsurl, fetch)

  const [xroot, xicon] = gen_xroot(crepo)
  const sroot = `/ts/${sname}/${sn_id}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link(xroot, crepo.vname, xicon, { kind: 'title', show: 'pl' }),
      nav_link(sroot, 'Chương tiết', 'list'),
    ],
  }

  return { xroot, sroot, crepo, xstem, rmemo: writable(rmemo), _meta }
}) satisfies LayoutLoad

const gen_xroot = ({ stype, sname, sn_id }) => {
  if (stype == 0) return [`/wn/${sn_id}`, 'book']
  if (stype == 1) return [`/up/${sname}:${sn_id}`, 'album']
  if (stype == 2) return [`/rm/${sname}:${sn_id}`, 'world']
  return '/wn'
}
