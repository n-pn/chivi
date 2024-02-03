import { chap_path, _pgidx } from '$lib/kit_path'

export const home_nav = (show: string = 'pl') => {
  return nav_link('/', 'Trang chủ', 'home', { show })
}

export const book_nav = (
  wn_id: number | string,
  vname: string,
  show = 'tm'
) => {
  return nav_link(`/wn/${wn_id}`, vname, 'book', { show, kind: 'title' })
}

export const nav_link = (
  href: string,
  text: string | null,
  icon: string | null,
  opts = {}
) => {
  return { type: 'a', href, icon, text, opts }
}
