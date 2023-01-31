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
const qtran_icons = { notes: 'notes', posts: 'user', links: 'link', crits: 'stars', }

const error: App.PageMeta = {
  title: 'Lỗi hệ thống',
  left_nav: [home_nav('tm'), { text: 'Lỗi hệ thống', href: '.' }],
}

type PageMetaFn = (data: Record<string, any>) => App.PageMeta
const meta_map: Record<string, App.PageMeta | PageMetaFn> = {
  '/': {
    title: 'Trang chủ',
    desc: 'Truyện Tàu dịch máy, đánh giá truyện, dịch nhanh tiếng Trung...',
    left_nav: [home_nav('ps')],
    right_nav: [
      nav_link('/qtran', 'Dịch nhanh', 'bolt', { show: 'tm' }),
      nav_link('/ys/crits', 'Đánh giá', 'stars', { show: 'tm' }),
    ],
  },
  // authenticate
  '/_auth/login': {
    title: 'Đăng nhập',
    left_nav: [home_nav('ps'), nav_link('login', 'Đăng nhập', 'login')],
  },
  '/_auth/signup': {
    title: 'Đăng ký',
    left_nav: [home_nav('ps'), nav_link('signup', 'Đăng ký', 'user-plus')],
  },
  '/_auth/passwd': {
    title: 'Quên mật khẩu',
    left_nav: [home_nav('ps'), nav_link('passwd', 'Quên mật khẩu', 'key')],
  },
  // dictionary management
  '/dicts': {
    title: 'Từ điển',
    left_nav: [home_nav('ps'), nav_link('/dicts', 'Từ điển', 'package')],
  },
  '/dicts/[dict]': ({ label, dname }) => {
    return {
      title: 'Từ điển:' + label,
      left_nav: [
        home_nav('ps'),
        nav_link('/dicts', 'Từ điển', 'package', { show: 'ts' }),
        nav_link(dname, label, '', { kind: 'title' }),
      ],
    }
  },
  // forum pages
  '/forum': {
    title: 'Diễn đàn',
    left_nav: [home_nav('tm'), nav_link('/forum', 'Diễn đàn', 'messages')],
  },

  // quick trans pages
  '/qtran': {
    title: 'Dịch nhanh',
    desc: 'Dịch nhanh từ tiếng Trung sang tiếng Việt',
    left_nav: [home_nav('tm'), nav_link('/qtran', 'Dịch nhanh', 'bolt')],
  },
  '/qtran/[type]/[name]': ({ type, name }) => ({
    title: `Dịch nhanh: [${type}/${name}]`,
    desc: 'Dịch nhanh từ tiếng Trung sang tiếng Việt',
    left_nav: [
      home_nav('tm'),
      nav_link('/qtran', 'Dịch nhanh', 'bolt', { show: 'ts' }),
      // prettier-ignore
      nav_link(name, `[${name}]`, qtran_icons[type], { kind: 'title', }),
    ],
    show_config: true,
  }),

  // yousuu review pages
  '/ys/crits': {
    title: 'Đánh giá truyện',
    left_nav: [home_nav('tm'), nav_link('/ys/crits', 'Đánh giá', 'stars')],
    right_nav: [nav_link('/ys/lists', 'Thư đơn', 'bookmarks', { show: 'tm' })],
  },
  '/ys/crits/[crit]': ({ entry: { id: crit_id }, vbook }) => ({
    title: `Đánh giá [${crit_id}]`,
    desc: `Đánh giá cho bộ truyện ${vbook.btitle}`,
    left_nav: [
      home_nav('', ''),
      nav_link('/ys/crits', 'Đánh giá truyện', 'stars', { show: 'tm' }),
      nav_link(crit_id, `[${crit_id}]`, null, { kind: 'zseed' }),
    ],
    right_nav: [nav_link('/ys/lists', 'Thư đơn', 'bookmarks', { show: 'tm' })],
  }),

  // yousuu booklist pages
  '/ys/lists': {
    title: 'Thư đơn',
    left_nav: [home_nav('tm'), nav_link('/ys/lists', 'Thư đơn', 'bookmarks')],
    right_nav: [nav_link('/ys/crits', 'Đánh giá', 'stars', { show: 'tm' })],
  },
  '/ys/lists/[list]': ({ ylist }) => {
    if (!ylist) return error
    const { id, vname, vdesc, vslug, uslug } = ylist

    return {
      title: `Thư đơn: ${vname}`,
      desc: vdesc,
      left_nav: [
        home_nav('', ''),
        nav_link('/ys/lists', 'Thư đơn', 'bookmarks', { show: 'tm' }),
        nav_link(`${id}${vslug}-${uslug}`, vname, null, { kind: 'title' }),
      ],
      right_nav: [nav_link('/ys/crits', 'Đánh giá', 'stars', { show: 'tm' })],
    }
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
  '/wn/[wn_id]-[[s]]/chaps/[sname]/(list)/+chap': ({ nvinfo, curr_seed }) => {
    if (!nvinfo || !curr_seed) return error
    const { bslug, btitle_vi: vname } = nvinfo

    return {
      title: 'Thêm/sửa chương truyện ' + vname,
      left_nav: [
        home_nav('', ''),
        book_nav(bslug, '', 'tl'),
        seed_nav(bslug, curr_seed.sname),
        nav_link('+chap', 'Thêm/sửa chương', 'file-plus', { show: 'pm' }),
      ],
    }
  },
  '/wn/[wn_id]-[[s]]/chaps/[sname]/(list)/+conf': ({ nvinfo }) => {
    if (!nvinfo) return error

    return {
      title: 'Tinh chỉnh nguồn chương truyện ' + nvinfo.btitle_vi,
      left_nav: [
        home_nav('', ''),
        book_nav(nvinfo.bslug, '', 'tl'),
        nav_link('+conf', 'Tinh chỉnh', 'settings', { show: 'pm' }),
      ],
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
