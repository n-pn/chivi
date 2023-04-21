import { home_nav, book_nav, seed_nav, nav_link } from '$utils/header_util'

export const load = async ({ parent }) => {
  const { nvinfo, curr_seed } = await parent()

  const _meta = {
    title: 'Cài đặt nguồn chương tiết truyện ' + nvinfo.vtitle,
    left_nav: [
      book_nav(nvinfo.bslug, nvinfo.vtitle, 'ts'),
      seed_nav(nvinfo.bslug, curr_seed.sname, 0, 'pl'),
      nav_link('+conf', 'Cài đặt', 'settings', { show: 'pm' }),
    ],
  }

  return { _meta }
}
