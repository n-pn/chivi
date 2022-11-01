import { nvinfo_bar } from '$utils/topbar_utils'
import { seed_url, to_pgidx } from '$utils/route_utils'

import { get, type Writable } from 'svelte/store'
import { config } from '$lib/stores'

throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ params, stuff }) {
  const { api, nvinfo, nvseed, ubmemo, nslist } = stuff
  const { sname, chidx, cpart: slug } = params
  const cpart = +slug.split('/')[1] || 1

  const api_url = gen_api_url(nvinfo, sname, chidx, cpart - 1, false)
  const api_res = await api.call(api_url)
  if (api_res.error) throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return api_res

  const topbar = gen_topbar(nvinfo, sname, chidx)
  const props = Object.assign(api_res, { nvinfo, nvseed, nslist })

  props.redirect = slug == ''
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props, stuff: { topbar } }
}

function gen_topbar(nvinfo: CV.Nvinfo, sname: string, chidx: number) {
  const list_url = seed_url(nvinfo.bslug, sname, to_pgidx(chidx))

  return {
    left: [
      nvinfo_bar(nvinfo, { show: 'pl' }),
      [sname, 'list', { href: list_url, kind: 'zseed' }],
    ],
    right: [],
    config: true,
  }
}

function gen_api_url(
  { id: book },
  sname: string,
  chidx: number,
  cpart = 0,
  redo = false
) {
  let api_url = `/api/chaps/${book}/${sname}/${chidx}/${cpart}?redo=${redo}`

  const { tosimp, w_temp } = get(config)
  if (tosimp) api_url += '&trad=t'
  if (w_temp) api_url += '&temp=t'

  return api_url
}
