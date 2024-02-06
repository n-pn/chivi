import { api_get } from '$lib/api_call'
import { home_nav, book_nav } from '$utils/header_util'
import { writable } from 'svelte/store'

import type { LayoutData } from './$types'

type RepoData = {
  rmemo: CV.Rdmemo
  crepo: CV.Tsrepo
}

export const load = (async ({ parent, params, fetch }) => {
  const { _navs } = await parent()

  const wn_id = parseInt(params.wn, 10)

  const rdpath = `/_rd/tsrepos/wn~avail/${wn_id}`
  const { rmemo, crepo } = await api_get<RepoData>(rdpath, fetch)

  const wnpath = `/_db/books/${wn_id}/show`
  const nvinfo = await api_get<CV.Wninfo>(wnpath, fetch)

  return {
    nvinfo,
    crepo,
    rmemo: writable(rmemo),
    _prev: { show: 'pl', text: 'Thư viện' },

    _navs: [..._navs, { href: `/wn/${wn_id}`, text: nvinfo.vtitle, icon: 'book', kind: 'title' }],
    _meta: {
      title: nvinfo.vtitle,
      image: nvinfo.bcover || '//cdn.chivi.app/covers/_blank.webp',
      mdesc: nvinfo.bintro.substring(0, 300),
    },
  }
}) satisfies LayoutData
