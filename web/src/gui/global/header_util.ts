import { chap_url } from '$utils/route_utils'

export function gen_meta(data: Record<string, any>): App.PageMeta {
  const meta = meta_map[data._path]
  if (typeof meta == 'function') return meta(data)
  return (meta || meta_map.index) as App.PageMeta
}

// prettier-ignore
const home_nav = (show: string) => nav_link('/', 'Chivi', null, { show, kind: 'brand' })

// prettier-ignore
const qtran_icons = { notes: 'notes', posts: 'user', links: 'link', crits: 'stars', }

type PageMetaFn = (data: Record<string, any>) => App.PageMeta
const meta_map: Record<string, App.PageMeta | PageMetaFn> = {
  index: {
    title: 'Trang chủ',
    desc: 'Truyện Tàu dịch máy, đánh giá truyện, dịch nhanh tiếng Trung...',

    left_nav: [home_nav('ps')],
    right_nav: [
      nav_link('/qtran', 'Dịch nhanh', 'bolt', { show: 'tm' }),
      nav_link('/ys/crits', 'Đánh giá', 'stars', { show: 'tm' }),
    ],
  },
  // forum pages
  forum: {
    title: 'Diễn đàn',
    left_nav: [home_nav('tm'), nav_link('/forum', 'Diễn đàn', 'messages')],
  },

  // quick trans pages
  qtran: {
    title: 'Dịch nhanh',
    desc: 'Dịch nhanh từ tiếng Trung sang tiếng Việt',
    left_nav: [home_nav('tm'), nav_link('/qtran', 'Dịch nhanh', 'bolt')],
  },
  qtran_post: ({ name, type }) => ({
    title: 'Dịch nhanh: ' + name,
    desc: 'Dịch nhanh từ tiếng Trung sang tiếng Việt',
    left_nav: [
      home_nav('tm'),
      nav_link('/qtran', 'Dịch nhanh', 'bolt', { show: 'ts' }),
      // prettier-ignore
      nav_link(`/qtran/${name}`, `[${name}]`, qtran_icons[type], { kind: 'title', }),
    ],
    show_config: true,
  }),

  // yousuu review pages
  ycrit_idx: {
    title: 'Đánh giá truyện',
    left_nav: [home_nav('tm'), nav_link('/ys/crits', 'Đánh giá', 'stars')],
    right_nav: [nav_link('/ys/lists', 'Thư đơn', 'bookmarks', { show: 'tm' })],
  },
  ycrit_show: ({ crit_id }) => ({
    title: 'Đánh giá',
    left_nav: [
      home_nav('tm'),
      nav_link('/ys/crits', 'Đánh giá truyện', 'stars', { show: 'tm' }),
      nav_link(`/ys/crits/${crit_id}`, `[${crit_id}]`, null, { kind: 'zseed' }),
    ],
    right_nav: [nav_link('/ys/lists', 'Thư đơn', 'bookmarks', { show: 'tm' })],
  }),
  // yousuu booklist pages
  ylist_idx: {
    title: 'Thư đơn',
    left_nav: [home_nav('tm'), nav_link('/ys/lists', 'Thư đơn', 'bookmarks')],
    right_nav: [nav_link('/ys/crits', 'Đánh giá', 'stars', { show: 'tm' })],
  },
  ylist_show: ({ ylist: { id, vname, vdesc, vslug } }) => ({
    title: `Thư đơn: ${vname}`,
    desc: vdesc,
    left_nav: [
      home_nav('tm'),
      nav_link('/ys/lists', 'Thư đơn', 'bookmarks', { show: 'tm' }),
      nav_link(`/ys/lists/${id}${vslug}`, vname, null, { kind: 'title' }),
    ],
    right_nav: [nav_link('/ys/crits', 'Đánh giá', 'stars', { show: 'tm' })],
  }),
}

function nav_link(
  href: string,
  text: string | null,
  icon: string | null,
  opts = {}
) {
  const res = { type: 'a', href, icon, text }
  for (const [key, val] of Object.entries(opts)) res['data-' + key] = val
  return res
}

function right_btn(text: string, icon: string, opts = {}) {
  const res = { type: 'button', text, icon }
  for (const [key, val] of Object.entries(opts)) res['data-' + key] = val
  return res
}

function quick_read_v1({ bslug }, ubmemo: CV.Ubmemo): App.HeadItem {
  return {
    'text': ubmemo.chidx > 0 ? 'Đọc tiếp' : 'Đọc thử',
    'icon': ubmemo.locked ? 'player-skip-forward' : 'player-play',
    'href': chap_url(bslug, ubmemo),
    'data-show': 'tm',
  }
}
