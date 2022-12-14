// export const ssr = false

import { set_fetch, api_path, api_get } from '$lib/api_call'

export async function load({ parent, params, fetch }) {
  const { nvinfo } = await parent()
  set_fetch(fetch)

  const args = [nvinfo.id, params.sname]
  const path = api_path('chroots.show', args)

  return { nvseed: await api_get(path) }
}
