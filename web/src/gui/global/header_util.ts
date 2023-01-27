import { chap_path, fix_sname, seed_path } from '$lib/kit_path'

export function gen_meta(route: string, data: Record<string, any>) {
  const meta = meta_map[route]
  if (!meta) console.log({ route })

  if (typeof meta == 'function') return meta(data)
  return (meta || meta_map['/']) as App.PageMeta
}

const home_nav = (show: string = 'tm', title = 'Chivi') => {
  return nav_link('/', title, null, { show, kind: 'brand' })
}

const book_nav = (bslug: string, vname: string, show = '') => {
  return nav_link(`/wn/${bslug}`, vname, 'book', { show, kind: 'title' })
}

const seed_nav = (bslug: string, sname: string, s_bid: string | number) => {
  const seed_href = seed_path(bslug, sname, s_bid)
  const seed_name = sname == '_' ? 'Tổng hợp' : sname
  return nav_link(seed_href, seed_name, 'list', { show: 'pl' })
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

function quick_read_v2({ bslug }, { sname, chidx, locked }) {
  sname = fix_sname(sname)

  return {
    'text': chidx > 0 ? 'Đọc tiếp' : 'Đọc thử',
    'icon': locked ? 'player-skip-forward' : 'player-play',
    'href': chap_path(bslug, { sname, snvid: '' }, chidx),
    'data-show': 'tm',
  } as App.HeadItem
}

// prettier-ignore
const qtran_icons = { notes: 'notes', posts: 'user', links: 'link', crits: 'stars', }

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
  '/ys/lists/[list]': ({ ylist: { id, vname, vdesc, vslug, uslug } }) => ({
    title: `Thư đơn: ${vname}`,
    desc: vdesc,
    left_nav: [
      home_nav('', ''),
      nav_link('/ys/lists', 'Thư đơn', 'bookmarks', { show: 'tm' }),
      nav_link(`${id}${vslug}-${uslug}`, vname, null, { kind: 'title' }),
    ],
    right_nav: [nav_link('/ys/crits', 'Đánh giá', 'stars', { show: 'tm' })],
  }),

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
  '/wn/[wn_id]-[[bslug]]/(info)': ({ nvinfo, ubmemo }) => {
    return {
      title: `${nvinfo.btitle_vi}`,
      desc: nvinfo.bintro.substring(0, 300),
      left_nav: [
        home_nav('tm'),
        book_nav(nvinfo.bslug, nvinfo.btitle_vi, 'tm'),
      ],
      right_nav: [quick_read_v2(nvinfo, ubmemo)],
    }
  },
  '/wn/[wn_id]-[[bslug]]/(info)/crits': ({ nvinfo }) => {
    return {
      title: `${nvinfo.btitle_vi}`,
      desc: nvinfo.bintro.substring(0, 300),
      left_nav: [
        home_nav('', ''),
        book_nav(nvinfo.bslug, nvinfo.btitle_vi, 'tm'),
        nav_link('crits', 'Đánh giá truyện', 'stars'),
      ],
      right_nav: [nav_link('crits/+crit', 'Đánh giá', 'circle-plus')],
    }
  },
  '/wn/[wn_id]-[[bslug]]/(info)/crits/+crit': ({ nvinfo }) => {
    return {
      title: `${nvinfo.btitle_vi}`,
      desc: nvinfo.bintro.substring(0, 300),
      left_nav: [
        home_nav('', ''),
        book_nav(nvinfo.bslug, '', 'tm'),
        nav_link('.', 'Đánh giá truyện', 'stars'),
        nav_link('+crit', 'Của bạn', 'user'),
      ],
      right_nav: [nav_link('../lists', 'Thư đơn', 'bookmarks')],
    }
  },
  '/wn/[wn_id]-[[bslug]]/+info': ({ nvinfo }) => {
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
  // book chapters
  '/wn/[wn_id]-[[bslug]]/(info)/lists': ({ nvinfo }) => {
    return {
      title: `${nvinfo.btitle_vi}`,
      desc: nvinfo.bintro.substring(0, 300),
      left_nav: [
        home_nav('', ''),
        book_nav(nvinfo.bslug, nvinfo.btitle_vi, 'tm'),
        nav_link('lists', 'Thư đơn', 'bookmarks'),
      ],
      right_nav: [nav_link('lists/+list', 'Thư đơn', 'circle-plus')],
    }
  },

  '/wn/[wn_id]-[[bslug]]/chaps/[sname]/(list)': ({ nvinfo, ubmemo }) => {
    return {
      title: `Chương tiết truyện  ${nvinfo.btitle_vi}`,
      desc: nvinfo.bintro.substring(0, 300),
      left_nav: [
        home_nav('', ''),
        book_nav(nvinfo.bslug, nvinfo.btitle_vi, 'ts'),
        nav_link('../chaps', 'Chương tiết', 'list', { show: 'pm' }),
      ],
      right_nav: [quick_read_v2(nvinfo, ubmemo)],
    }
  },
  '/wn/[wn_id]-[[bslug]]/chaps/+seed': ({ nvinfo, ubmemo }) => {
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
  '/wn/[wn_id]-[[bslug]]/chaps/[sname]/(list)/+chap': ({
    nvinfo,
    curr_seed,
  }) => {
    const { bslug, btitle_vi: vname } = nvinfo
    const { sname, snvid } = curr_seed

    return {
      title: 'Thêm/sửa chương truyện ' + vname,
      left_nav: [
        home_nav('', ''),
        book_nav(bslug, '', 'tl'),
        seed_nav(bslug, sname, snvid),
        nav_link('+chap', 'Thêm/sửa chương', 'file-plus', { show: 'pm' }),
      ],
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
