export const load = async ({ parent }) => {
  const { sroot, crepo } = await parent()

  // _meta: {
  //   left_nav: [
  //     nav_link(sroot, crepo.vname, 'article', { kind: 'title' }),
  //     nav_link('ul', 'Đăng tải', 'upload', { show: 'pm' }),
  //   ],
  // },
  return {
    ontab: 'cf',
    _meta: { title: `Cài đặt nguồn truyện - ${crepo.vname}` },
  }
}
