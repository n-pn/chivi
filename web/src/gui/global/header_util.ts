import { chap_path, fix_sname, seed_path, _pgidx } from '$lib/kit_path'

export function gen_meta(route: string, data: Record<string, any>) {
  const meta = meta_map[route]
  if (!meta) console.log({ route })

  if (typeof meta == 'function') return meta(data)
  return (meta || meta_map['/']) as App.PageMeta
}

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

  const seed_name = sname == '_' ? '[Tổng hợp]' : `[${sname}]`
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

function quick_read_v2({ bslug }, { sname, chidx, locked }) {
  sname = fix_sname(sname)

  return {
    'text': chidx > 0 ? 'Đọc tiếp' : 'Đọc thử',
    'icon': locked ? 'player-skip-forward' : 'player-play',
    'href': chap_path(bslug, sname, chidx),
    'data-show': 'tm',
  } as App.HeadItem
}

// prettier-ignore

const error: App.PageMeta = {
  title: 'Lỗi hệ thống',
  left_nav: [home_nav('tm'), { text: 'Lỗi hệ thống', href: '.' }],
}

type PageMetaFn = (data: Record<string, any>) => App.PageMeta
const meta_map: Record<string, App.PageMeta | PageMetaFn> = {
  // forum pages
  '/forum': {
    title: 'Diễn đàn',
    left_nav: [home_nav('tm'), nav_link('/forum', 'Diễn đàn', 'messages')],
  },
  // new book pages
  '/wn': {
    title: 'Danh sách truyện',
    left_nav: [
      home_nav('tm'),
      nav_link('/wn', 'Danh sách truyện', 'books', { kind: 'title' }),
    ],
    right_nav: [
      nav_link('/books/+book', 'Thêm truyện', 'file-plus', { show: 'tm' }),
    ],
  },
  '/wn/[wn_id]-[[s]]/(info)': ({ nvinfo, ubmemo }) => {
    if (!nvinfo) return error

    return {
      title: `${nvinfo.btitle_vi}`,
      desc: nvinfo.bintro.substring(0, 300),
      left_nav: [home_nav(''), book_nav(nvinfo.bslug, nvinfo.btitle_vi, '')],
      right_nav: [quick_read_v2(nvinfo, ubmemo)],
    }
  },
  '/wn/[wn_id]-[[s]]/+info': ({ nvinfo }) => {
    if (!nvinfo) return error
    return {
      title: `Sửa thông tin truyện: ${nvinfo.btitle_vi}`,
      desc: 'Sửa thông tin truyện',
      left_nav: [
        home_nav('', ''),
        book_nav(nvinfo.bslug, nvinfo.btitle_vi, 'tm'),
        nav_link('+info', 'Sửa thông tin', 'pencil'),
      ],
    }
  },
  '/wn/[wn_id]-[[s]]/(info)/crits': ({ nvinfo }) => {
    if (!nvinfo) return error

    return {
      title: `${nvinfo.btitle_vi}`,
      desc: nvinfo.bintro.substring(0, 300),
      left_nav: [
        home_nav('', ''),
        book_nav(nvinfo.bslug, nvinfo.btitle_vi, 'tm'),
        nav_link('crits', 'Đánh giá', 'stars'),
      ],
      right_nav: [
        nav_link('crits/+crit', 'Đánh giá', 'circle-plus', { show: 'tl' }),
      ],
    }
  },
  '/wn/[wn_id]-[[s]]/(info)/crits/+crit': ({ nvinfo }) => {
    if (!nvinfo) return error

    return {
      title: `${nvinfo.btitle_vi}`,
      desc: nvinfo.bintro.substring(0, 300),
      left_nav: [
        home_nav('', ''),
        book_nav(nvinfo.bslug, 'book-open', 'pl'),
        nav_link('.', 'Đánh giá', 'stars', { show: 'ts' }),
        nav_link('+crit', 'Thêm đánh giá', 'circle-plus', { show: 'pl' }),
      ],
      right_nav: [nav_link('../lists', 'Thư đơn', 'bookmarks', { show: 'tl' })],
    }
  },

  // book chapters
  '/wn/[wn_id]-[[s]]/(info)/lists': ({ nvinfo }) => {
    if (!nvinfo) return error

    return {
      title: `${nvinfo.btitle_vi}`,
      desc: nvinfo.bintro.substring(0, 300),
      left_nav: [
        home_nav('', ''),
        book_nav(nvinfo.bslug, nvinfo.btitle_vi, 'tm'),
        nav_link('lists', 'Thư đơn', 'bookmarks'),
      ],
      right_nav: [
        nav_link('lists/+list', 'Thư đơn', 'circle-plus', { show: 'tl' }),
      ],
    }
  },

  '/wn/[wn_id]-[[s]]/chaps/[sname]/(list)': ({ nvinfo, ubmemo }) => {
    if (!nvinfo || !ubmemo) return error

    return {
      title: `Chương tiết truyện  ${nvinfo.btitle_vi}`,
      desc: nvinfo.bintro.substring(0, 300),
      left_nav: [
        home_nav('', ''),
        book_nav(nvinfo.bslug, nvinfo.btitle_vi, 'ts'),
        nav_link('../chaps', 'Chương tiết', 'list', { show: 'pl' }),
      ],
      right_nav: [quick_read_v2(nvinfo, ubmemo)],
    }
  },
  '/wn/[wn_id]-[[s]]/chaps/+seed': ({ nvinfo, ubmemo }) => {
    if (!nvinfo || !ubmemo) return error

    return {
      title: `Thêm nguồn truyện: ${nvinfo.btitle_vi}`,
      desc: `Quản lý nguồn truyện cho bộ truyện ${nvinfo.btitle_vi}`,
      left_nav: [
        home_nav('', ''),
        book_nav(nvinfo.bslug, '', 'tl'),
        nav_link('.', 'Chương tiết', 'list', { show: 'pm' }),
        nav_link('+seed', 'Nguồn chương', 'pencil'),
      ],
      right_nav: [quick_read_v2(nvinfo, ubmemo)],
    }
  },

  '/wn/[wn_id]-[[s]]/chaps/[sname]/[ch_no]/[[cpart]]': (data) => {
    const { nvinfo, curr_seed, curr_chap } = data
    if (!(nvinfo && curr_seed && curr_chap)) return error

    const { bslug } = nvinfo
    const { title, uslug, chidx: ch_no } = curr_chap

    const chap_href = chap_path(bslug, curr_seed.sname, ch_no, uslug)

    return {
      title: `${title} - ${nvinfo.btitle_vi}`,
      left_nav: [
        book_nav(bslug, nvinfo.btitle_vi, 'tm'),
        seed_nav(bslug, curr_seed.sname, _pgidx(ch_no), 'ts'),
        nav_link(chap_href, `Ch. ${ch_no}`, '', { show: 'lg', kind: 'uname' }),
      ],
      show_config: true,
    }
  },
}

// function right_btn(text: string, icon: string, opts = {}) {
//   const res = { type: 'button', text, icon }
//   for (const [key, val] of Object.entries(opts)) res['data-' + key] = val
//   return res
// }

// function quick_read_v1({ bslug }, ubmemo: CV.Ubmemo): App.HeadItem {
//   return {
//     'text': ubmemo.chidx > 0 ? 'Đọc tiếp' : 'Đọc thử',
//     'icon': ubmemo.locked ? 'player-skip-forward' : 'player-play',
//     'href': chap_url(bslug, ubmemo),
//     'data-show': 'tm',
//   }
// }
