import { getContext } from 'svelte'
import type { Writable } from 'svelte/store'

import { session, page } from '$app/stores'

throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ stuff, url, params: { sname } }) {
  const { api, nvinfo } = stuff

  const pgidx = +url.searchParams.get('pg') || 1
  const chlist = await api.chlist(nvinfo.id, sname, pgidx)
  if (chlist.error) throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return chlist

  const props = Object.assign(stuff, { chlist })

  return props
}
