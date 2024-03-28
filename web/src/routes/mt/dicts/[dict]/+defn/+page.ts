import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params: { dict }, parent }) => {
  const { dinfo } = await parent()

  const form = init_form(url.searchParams)
  let prev: CV.Zvdefn

  if (form.zstr && form.cpos) {
    const url = `/_sp/zvdefns/find?dict=${dict}&zstr=${form.zstr}&cpos=${form.cpos}`
    const res = await fetch(url)
    if (res.ok) {
      prev = await res.json()
      form.attr ||= prev.attr
      form.vstr ||= prev.vstr
      form.lock ||= prev.lock
    } else {
      console.log(await res.text())
    }
  }

  const _meta = {
    left_nav: [
      nav_link('/mt/dicts', 'Từ điển', 'package', { show: 'tm' }),
      nav_link('.', dinfo.label, '', { kind: 'title' }),
      nav_link('+term', 'Thêm sửa từ', '', { show: 'pl' }),
    ],
  }

  const _title = 'Từ điển: ' + dinfo.label

  return { dict, form, prev, _meta, _title }
}) satisfies PageLoad

function init_form(params: URLSearchParams) {
  return {
    zstr: params.get('zstr') || '',
    vstr: params.get('vstr') || '',
    cpos: params.get('cpos') || '',
    attr: params.get('attr') || '',
    lock: +params.get('lock'),
  }
}
