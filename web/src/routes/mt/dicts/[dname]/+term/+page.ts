import { home_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params: { dname }, parent }) => {
  const { dinfo } = await parent()

  const form = init_form(url.searchParams)
  let prev: CV.Viterm

  if (form.zstr && form.cpos) {
    const url = `/_ai/terms/find?dict=${dname}&zstr=${form.zstr}&cpos=${form.cpos}`
    const res = await fetch(url)
    if (res.ok) {
      prev = await res.json()
      form.attr ||= prev.attr
      form.vstr ||= prev.vstr
    } else {
      console.log(await res.text())
    }
  }

  const _meta = {
    left_nav: [
      nav_link(dname, dinfo.label, 'package', { kind: 'title' }),
      nav_link('+term', 'Thêm sửa từ', '', { show: 'pl' }),
    ],
  }

  const _title = 'Từ điển: ' + dinfo.label

  return { dname, form, prev }
}) satisfies PageLoad

function init_form(params: URLSearchParams) {
  return {
    zstr: params.get('zstr') || '',
    vstr: params.get('vstr') || '',
    cpos: params.get('cpos') || '',
    attr: params.get('attr') || '',
  }
}
