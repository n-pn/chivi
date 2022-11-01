const _meta: App.PageMeta = {
  title: 'Thêm truyện mới',
  // prettier-ignore
  left_nav: [
    { text: 'Thư viện', icon: 'books', href: '/books', 'data-show': 'md' },
    { 'text': 'Thêm truyện mới', 'icon': 'file-plus', 'href': '/books/+book' }
  ],
}

export function load() {
  return { _meta }
}
