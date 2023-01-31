import { home_nav, book_nav, seed_nav, nav_link } from '$gui/global/header_util'

export const load = async ({ parent }) => {
  const { nvinfo, curr_seed } = await parent()

  const _meta = {
    title: 'Tinh chỉnh nguồn chương truyện ' + nvinfo.btitle_vi,
    left_nav: [
      book_nav(nvinfo.bslug, nvinfo.btitle_vi, 'ts'),
      seed_nav(nvinfo.bslug, curr_seed.sname, 0, 'pl'),
      nav_link('+conf', 'Tinh chỉnh', 'settings', { show: 'pm' }),
    ],
  }

  return { _meta }
}
