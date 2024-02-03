import { api_get } from '$lib/api_call'
import { writable } from 'svelte/store'
import type { LayoutLoad } from './$types'

interface LayoutData {
  crepo: CV.Tsrepo
  rmemo: CV.Rdmemo
  xstem: CV.Upstem | CV.Wnstem | CV.Rmstem
}

export const load = (async ({ fetch, params, parent }) => {
  const { _navs } = await parent()

  const sname = params.sname
  const sn_id = parseInt(params.sn_id)

  const tsurl = `/_rd/tsrepos/${sname}/${sn_id}`
  const { crepo, rmemo, xstem } = await api_get<LayoutData>(tsurl, fetch)

  const [xroot, xicon] = gen_xroot(crepo)
  const sroot = `/ts/${sname}/${sn_id}`

  return {
    crepo,
    xstem,
    xroot,
    sroot,
    rmemo: writable(rmemo),

    _navs: [
      ..._navs,
      {
        href: xroot,
        text: crepo.vname,
        hd_icon: xicon,
        hd_kind: 'title',
        hd_show: 'pl',
      },
      { href: sroot, text: 'Chương tiết', hd_icon: 'list' },
    ],
  }
}) satisfies LayoutLoad

const gen_xroot = ({ stype, sname, sn_id }) => {
  if (stype == 0) return [`/wn/${sn_id}`, 'book']
  if (stype == 1) return [`/up/${sname}/${sn_id}`, 'album']
  if (stype == 2) return [`/rm/${sname}/${sn_id}`, 'world']
  return '/wn'
}
