import { home_nav, nav_link } from '$utils/header_util'

import { api_get } from '$lib/api_call'

type Data = { cvmtl: string; ztext: string }

const qtran_icons = {
  notes: 'notes',
  posts: 'user',
  links: 'link',
  crits: 'stars',
}

export async function load({ fetch, url, params: { name } }) {
  const pdict = +url.searchParams.get('d')
  const path = `/_m1/qtran/cached/?type=${type}&name=${name}&wn_id=${wn_id}`

  const _meta: App.PageMeta = {
    left_nav: [
      home_nav('tm'),
      nav_link('/sp/qtran', 'Dịch nhanh', 'bolt', { show: 'ts' }),
      nav_link(name, `[${name}]`, qtran_icons[type], { kind: 'title' }),
    ],
  }

  const { cvmtl, ztext } = await api_get<Data>(path, fetch)

  return {
    cvmtl,
    ztext,
    wn_id,
    _meta,
    _title: `Dịch nhanh: [${type}/${name}]`,
    _mdesc: 'Dịch nhanh từ tiếng Trung sang tiếng Việt',
  }
}
