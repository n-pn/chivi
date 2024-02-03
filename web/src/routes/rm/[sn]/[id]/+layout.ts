import { api_get } from '$lib/api_call'
import { writable } from 'svelte/store'
import type { LayoutLoad } from './$types'

interface RmstemShow {
  xstem: CV.Rmstem
  crepo: CV.Tsrepo
  rmemo: CV.Rdmemo
}

export const load = (async ({ fetch, params }) => {
  const sname = params.sn
  const sn_id = params.id

  const sroot = `/rm/${sname}/${sn_id}`

  const rdurl = `/_rd/tsrepos/rm${sname}/${sn_id}`
  const { xstem: rstem, crepo, rmemo } = await api_get<RmstemShow>(rdurl, fetch)

  let binfo: CV.Wninfo

  if (rstem.wn_id) {
    const bpath = `/_db/books/${rstem.wn_id}/show`
    binfo = await api_get<CV.Wninfo>(bpath, fetch)
  }

  const _navs = [
    {
      href: '/rm',
      text: 'Nguồn nhúng',
    },
    {
      href: `/rm/${sname}`,
      text: sname,
      hd_icon: 'folder',
      hd_show: 'pl',
      hd_kind: 'zseed',
    },
    {
      href: `/rm/${sname}/${sn_id}`,
      text: `${rstem.btitle_vi} [ID: ${rstem.sn_id}]`,
      hd_text: rstem.btitle_vi,
      hd_icon: 'book',
      hd_kind: 'title',
    },
  ]

  return {
    rstem,
    crepo,
    rmemo: writable(rmemo),
    binfo,
    sname,
    sn_id,
    sroot,
    _navs,
  }
}) satisfies LayoutLoad
