import { nvinfo_bar } from '$utils/topbar_utils'
import { seed_url, to_pgidx } from '$utils/route_utils'

import { api_get, set_fetch } from '$lib/api_call'
import { gen_api_url } from './shared'

export async function load({ params, parent, fetch }) {
  const { nvinfo } = await parent()
  const { sname, chidx, cpart: slug } = params
  const cpart = +slug.split('/')[1] || 1

  set_fetch(fetch)
  // TODO: using `api_path()` to generate url
  const path = gen_api_url(nvinfo, sname, chidx, cpart - 1, false)
  const data = await api_get(path)

  const _meta = page_meta(nvinfo, data.chinfo.title, sname, +chidx)
  return { ...data, _meta, redirect: slug == '' }
}

// prettier-ignore
function page_meta( nvinfo: CV.Nvinfo, title: string, sname: string, chidx: number ): App.PageMeta {
  const list_url = seed_url(nvinfo.bslug, sname, to_pgidx(chidx))

  return {
    title: `${title} - ${nvinfo.btitle_vi}`,
    left_nav: [
      nvinfo_bar(nvinfo, { 'data-show': 'pl' }),
      { 'text': sname, 'icon': 'list', 'href': list_url, 'data-kind': 'zseed' },
    ],
    show_config: true,
  }
}
