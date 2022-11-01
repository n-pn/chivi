import { get_chlist } from '$lib/api'

export async function load({ parent, url, fetch, params: { sname } }) {
  const { nvinfo } = await parent()

  const pgidx = +url.searchParams.get('pg') || 1
  const chlist = await get_chlist(nvinfo.id, sname, pgidx, fetch)
  return { chlist }
}
