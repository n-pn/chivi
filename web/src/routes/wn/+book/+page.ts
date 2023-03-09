import { nav_link } from '$gui/global/header_util'

const _meta: App.PageMeta = {
  title: 'Thêm truyện mới',
  left_nav: [
    nav_link('/wn', 'Thư viện', 'books', { show: 'md' }),
    nav_link('/wn/+book', 'Thêm truyện mới', 'file-plus', { kind: 'title' }),
  ],
}

const wnform: CV.WnForm = {
  ztitle: '',
  vtitle: '',

  zauthor: '',
  vauthor: '',

  zintro: '',
  vintro: '',

  genres: [],

  bcover: '',
  status: 0,
}

export function load() {
  const nvinfo: Partial<CV.Nvinfo> = { id: 0 }
  return { nvinfo, wnform, _meta }
}
