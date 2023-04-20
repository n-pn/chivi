import { home_nav, nav_link } from '$utils/header_util'

import { api_get } from '$lib/api_call'

type Data = { cvmtl: string; ztext: string; wn_id: number }

const qtran_icons = {
  notes: 'notes',
  posts: 'user',
  links: 'link',
  crits: 'stars',
}

export async function load({ fetch, url, params: { type, name } }) {
  const wn_id = +url.searchParams.get('wn_id')
  const path = `/_m1/qtran/cached/?type=${type}&name=${name}&wn_id=${wn_id}`

  const _meta: App.PageMeta = {
    title: `Dịch nhanh: [${type}/${name}]`,
    desc: 'Dịch nhanh từ tiếng Trung sang tiếng Việt',
    left_nav: [
      home_nav('tm'),
      nav_link('/sp/qtran', 'Dịch nhanh', 'bolt', { show: 'ts' }),
      nav_link(name, `[${name}]`, qtran_icons[type], { kind: 'title' }),
    ],
    show_config: true,
  }

  const data = await api_get<Data>(path, fetch)
  return { ...data, _meta }
}
