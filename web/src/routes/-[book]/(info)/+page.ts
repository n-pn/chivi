import type { LoadEvent } from '@sveltejs/kit'
import { api_path, api_get, set_fetch } from '$lib/api_call'

export const load = async ({ fetch, parent }: LoadEvent) => {
  const { nvinfo } = await parent()
  set_fetch(fetch)

  const bdata = await load_bfront(nvinfo.bslug)
  const crits = await load_ycrits(nvinfo.id)
  return { ...bdata, crits: crits }
}

const load_bfront = async (bslug: string) => {
  const bhash = bslug.substring(0, 8)
  const bpath = api_path('nvinfos.front', bhash)
  return await api_get(bpath)
}

const load_ycrits = async (book: number) => {
  const extra = { book, sort: 'score', lm: 3 }
  const ypath = api_path('yscrits.index', null, null, extra)
  const ydata = (await api_get(ypath)) as { crits: CV.Yscrit[] }
  return ydata.crits
}
