import { nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  left_nav: [
    nav_link('.', 'Dịch máy', 'bolt'),
    nav_link('debug', 'Debug', 'bug'),
  ],
}

export const load = (({ url }) => {
  const ztext = url.searchParams.get('ztext') || ''
  const m_alg = url.searchParams.get('m_alg') || 'mtl_2'
  const pdict = url.searchParams.get('pdict') || 'combine'
  return { ztext, m_alg, pdict, _meta, _title: 'Debug' }
}) satisfies PageLoad
