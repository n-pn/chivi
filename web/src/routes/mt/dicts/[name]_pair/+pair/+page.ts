import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ parent, fetch, url, params }) => {
  const zform = init_form(params.name, url.searchParams)
  const { dname, a_key, b_key } = zform

  if (dname && a_key && b_key) {
    const url = `/_ai/terms/find?dname=${dname}&a_key=${a_key}&b_key=${b_key}`
    const res = await fetch(url)
    if (res.ok) {
      const prev = await res.json()
      zform.a_vstr ||= prev.a_vstr
      zform.a_attr ||= prev.a_attr
      zform.b_vstr ||= prev.b_vstr
      zform.b_attr ||= prev.b_attr
    }
  }

  const { _navs } = await parent()

  return {
    dname,
    zform,
    _meta: { title: 'Thêm sửa cặp từ' },
    _navs: [..._navs, { href: url.pathname, text: 'Thêm sửa', icon: 'plus', show: 'pl' }],
  }
}) satisfies PageLoad

function init_form(dname, params: URLSearchParams): Partial<CV.Zvpair> {
  return {
    dname,
    a_key: params.get('a_key') || '',
    b_key: params.get('b_key') || '',
    a_vstr: '',
    a_attr: '',
    b_vstr: '',
    b_attr: '',
  }
}
