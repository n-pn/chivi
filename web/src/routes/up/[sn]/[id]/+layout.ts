import { api_get } from '$lib/api_call'
import { writable } from 'svelte/store'
import type { LayoutLoad } from './$types'

interface UpstemShow {
  xstem: CV.Upstem
  crepo: CV.Tsrepo
  rmemo: CV.Rdmemo
}

export const load = (async ({ fetch, params }) => {
  const sname = params.sn
  const sn_id = +params.id

  const sroot = `/up/${sname}/${sn_id}`

  const rdurl = `/_rd/tsrepos/up${sname}/${sn_id}`
  const { xstem: ustem, rmemo, crepo } = await api_get<UpstemShow>(rdurl, fetch)

  let binfo: CV.Wninfo

  if (ustem.wn_id) {
    const bpath = `/_db/books/${ustem.wn_id}/show`
    binfo = await api_get<CV.Wninfo>(bpath, fetch)
  }

  rmemo.vname = ustem.vname
  rmemo.rpath = sroot

  return {
    ustem,
    crepo,
    binfo,
    sroot,
    rmemo: writable(rmemo),

    _prev: { text: sname.substring(1), icon: 'at' },
    _curr: { text: ustem.vname, kind: 'title', icon: 'book' },
    _navs: [
      { href: '/up', text: 'Sưu tầm ' },
      { href: `/up/${sname}`, text: sname },
      { href: `/up/${sname}/${sn_id}`, text: ustem.vname + ' ID: ' + sn_id },
    ],
  }
}) satisfies LayoutLoad
