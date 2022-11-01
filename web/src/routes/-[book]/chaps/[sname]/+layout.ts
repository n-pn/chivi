import { get_nvseed } from '$lib/api'

export async function load({ parent, params, fetch }) {
  const { nvinfo } = await parent()
  const nvseed = await get_nvseed(nvinfo.id, params.sname, 0, fetch)
  return { nvseed }
}
