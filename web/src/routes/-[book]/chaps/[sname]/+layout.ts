// export const ssr = false

import { redirect } from '@sveltejs/kit'
import { set_fetch, api_path, api_get } from '$lib/api_call'

import type { LayoutLoad } from './$types'

export const load = (async ({ parent, params: { sname }, fetch, url }) => {
  const prefix = sname[0]

  if (prefix != '@' && prefix != '=') {
    const location = url.pathname.replace(`/${sname}`, '/=base')
    throw redirect(300, location)
  }

  const { nvinfo } = await parent()
  set_fetch(fetch)

  const args = [nvinfo.id, sname]
  const path = api_path('chroots.show', args)

  return { nvseed: await api_get(path) }
}) satisfies LayoutLoad
