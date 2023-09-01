import { chap_path, fix_sname, seed_path, _pgidx } from '$lib/kit_path'

export const home_nav = (show: string = 'tm', title = 'Chivi') => {
  return nav_link('/', title, null, { show, kind: 'brand' })
}

export const book_nav = (bslug: string, vname: string, show = 'tm') => {
  return nav_link(`/wn/${bslug}`, vname, 'book', { show, kind: 'title' })
}

export const seed_nav = (
  bslug: string,
  sname: string,
  pg_no = 1,
  show = 'pl'
) => {
  const seed_href = seed_path(bslug, sname, pg_no)

  const seed_name = `[${sname}]`
  return nav_link(seed_href, seed_name, 'list', { kind: 'zseed', show })
}

export const nav_link = (
  href: string,
  text: string | null,
  icon: string | null,
  opts = {}
) => {
  const res = { type: 'a', href, icon, text }
  for (const [key, val] of Object.entries(opts)) res['data-' + key] = val
  return res
}

export const default_meta: App.PageMeta = {
  left_nav: [home_nav('ps')],
  right_nav: [
    nav_link('/sp/qtran', 'Dịch nhanh', 'bolt', { show: 'tm' }),
    nav_link('/wn/crits', 'Đánh giá', 'stars', { show: 'tm' }),
  ],
}

export function quick_read_v2({ bslug }, { sname, chidx, cpart, locked }) {
  sname = fix_sname(sname)

  return {
    'text': chidx > 0 ? 'Đọc tiếp' : 'Đọc thử',
    'icon': locked ? 'player-skip-forward' : 'player-play',
    'href': chap_path(bslug, sname, chidx, cpart),
    'data-show': 'tm',
  } as App.HeadItem
}
