/** @type {import('./[slug]').PageLoad} */
export async function load({ parent }) {
  const { nvinfo } = await parent()
  const _meta = page_meta(nvinfo)
  return { _meta }
}

function page_meta({ btitle_vi, bslug }) {
  return {
    title: 'Tinh chỉnh nguồn chương truyện ' + btitle_vi,
    // prettier-ignore
    nav_left: [
      { text: btitle_vi, icon: 'book', href: `/-${bslug}`, 'data-kind': 'title' },
      { text: 'Tinh chỉnh', icon: 'settings', href: '.', "data-show": 'pl' },
    ],
  }
}

function gen_topbar({ btitle_vi, bslug }) {
  return {
    left: [
      [btitle_vi, 'book', { href: `/-${bslug}`, kind: 'title' }],
      ['Tinh chỉnh', 'settings', { href: '.', show: 'pl' }],
    ],
  }
}
