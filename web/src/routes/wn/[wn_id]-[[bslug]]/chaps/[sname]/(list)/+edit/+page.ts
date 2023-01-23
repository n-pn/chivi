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
    left_nav: [
      { text: btitle_vi, icon: 'book', href: `/-${bslug}`, 'data-kind': 'title' },
      { text: 'Tinh chỉnh', icon: 'settings', href: '.', "data-show": 'pl' },
    ],
  }
}
