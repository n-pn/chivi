const _meta: App.PageMeta = {
  title: 'Thêm truyện mới',
  // prettier-ignore
  left_nav: [
    { text: 'Thư viện', icon: 'books', href: '/books', 'data-show': 'md' },
    { 'text': 'Thêm truyện mới', 'icon': 'file-plus', 'href': '/books/+book' }
  ],
}

const wnform: CV.WnForm = {
  btitle_zh: '',
  btitle_vi: '',
  author_zh: '',
  author_vi: '',

  bintro_zh: '',
  bintro_vi: '',

  genres: [],
  bcover: '',
  status: 0,
}

export function load() {
  const nvinfo: Partial<CV.Nvinfo> = { id: 0 }
  return { nvinfo, wnform, _meta }
}
