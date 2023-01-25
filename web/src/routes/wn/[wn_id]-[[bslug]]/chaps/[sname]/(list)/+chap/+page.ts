import type { PageLoad } from './$types'

export const load = (async ({ parent, url }) => {
  const { nvinfo } = await parent()
  const _meta = page_meta(nvinfo)
  const chidx = +url.searchParams.get('chidx') || 1
  return { chidx, _meta }
}) satisfies PageLoad

function page_meta({ btitle_vi, bslug }) {
  return {
    title: 'Thêm/sửa chương truyện ' + btitle_vi,
    // prettier-ignore
    left_nav: [
      { text: btitle_vi, icon: 'book', href: `/wn/${bslug}`, 'data-kind': 'title' },
      { text: 'Thêm/sửa chương', icon: 'file-plus', href: '.', "data-show": 'pl' },
    ],
  }
}