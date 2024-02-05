import type { PageLoad } from './$types'
import { load_crits } from '$lib/fetch_data'

export const load = (async ({ url, fetch, parent }) => {
  const { nvinfo } = await parent()

  const qdata = {
    wn: nvinfo.id,
    by: url.searchParams.get('by'),
    og: url.searchParams.get('og') || 'mixed',
    gt: +url.searchParams.get('gt') || 1,
    lt: +url.searchParams.get('lt') || 5,
    pg: +url.searchParams.get('pg') || 1,
    _s: url.searchParams.get('_s') || 'score',
    _m: url.searchParams.get('_m'),
  }

  const limit = qdata.og == 'mixed' ? 4 : 8
  const query = (url.search || '?_s=score') + `&lm=${limit}&wn=${nvinfo.id}`

  const { vdata, ydata } = await load_crits(qdata.og, query, fetch)

  return {
    vdata,
    ydata,
    qdata,
    ontab: 'crits',
    _meta: { title: `Đánh giá truyện: ${nvinfo.vtitle}` },
    _navs: [
      {
        href: '/wn',
        text: 'Thư viện truyện chữ',
        hd_text: 'Thư viện',
        hd_icon: 'books',
        hd_show: 'pl',
      },
      {
        href: `/wn/${nvinfo.id}`,
        text: nvinfo.vtitle,
        hd_icon: 'book',
        hd_kind: 'title',
        hd_show: 'pl',
      },
      {
        href: `/wn/${nvinfo.id}/crits`,
        text: 'Đánh giá',
        hd_icon: 'stars',
        hd_kind: 'title',
      },
    ],
    _alts: [
      {
        href: `/uc/crits/+crit?wn=${nvinfo.id}`,
        text: 'Tạo mới',
        hd_icon: 'square-plus',
        hd_kind: 'success',
        hd_show: 'tm',
      },
    ],
  }
}) satisfies PageLoad
