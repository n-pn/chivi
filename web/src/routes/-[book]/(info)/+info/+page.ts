import { nvinfo_bar } from '$utils/topbar_utils'

export async function load({ parent, fetch }) {
  const { nvinfo } = await parent()

  const api_url = `/api/books/${nvinfo.bslug.substr(0, 8)}/+edit`
  const api_res = await fetch(api_url)
  const payload = await api_res.json()

  const _meta = {
    title: 'Sửa thông tin truyện ' + nvinfo.btitle_vi,
    left: [
      nvinfo_bar(nvinfo, { 'data-show': 'tm' }),
      { text: 'Sửa thông tin', icon: 'pencil', href: './+info' },
    ],
  }

  return { _meta, ...payload }
}
