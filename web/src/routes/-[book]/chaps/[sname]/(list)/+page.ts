import { api_path } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ parent, fetch, url, params: { sname } }) => {
  const { nvinfo } = await parent()

  if (sname == '-') sname = '=base'

  const page = url.searchParams.get('pg') || 1
  const args = [nvinfo.id, sname, page]

  const path = api_path('chroots.chaps', args, url.searchParams)
  const chlist = await fetch(path).then((r) => r.json())
  return { chlist }
}) satisfies PageLoad
