import type { LoadEvent } from '@sveltejs/kit'
import { api_path } from '$lib/api_call'

export const load = async ({ fetch, parent }: LoadEvent) => {
  const { nvinfo } = await parent()

  const bhash = nvinfo.bslug.substring(0, 8)
  const bpath = api_path('nvinfos.front', bhash)

  const data = await fetch(bpath).then((r) => r.json())

  const extra = { book: nvinfo.id, take: 3, sort: 'score' }
  const ypath = api_path('yscrits.index', null, null, extra)

  const { crits } = (await fetch(ypath).then((r) => r.json())) as {
    crits: CV.Yscrit[]
  }

  return { ...data, crits }
}
