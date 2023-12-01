import { nav_link } from '$utils/header_util'

export const load = async ({ parent }) => {
  const { sroot, crepo } = await parent()

  return {
    ontab: 'cf',
    _title: `Cài đặt nguồn truyện - ${crepo.vname}`,
    _meta: {
      left_nav: [
        nav_link(sroot, crepo.vname, 'article', { kind: 'title' }),
        nav_link('ul', 'Đăng tải', 'upload', { show: 'pm' }),
      ],
    },
  }
}
