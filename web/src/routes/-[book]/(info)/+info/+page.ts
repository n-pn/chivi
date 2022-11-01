import { nvinfo_bar } from '$utils/topbar_utils'

throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ stuff, fetch }) {
  const { nvinfo } = stuff
  const api_url = `/api/books/${nvinfo.bslug.substr(0, 8)}/+edit`
  const api_res = await fetch(api_url)
  const payload = await api_res.json()

  const topbar = {
    left: [
      nvinfo_bar(nvinfo, { show: 'tm' }),
      ['Sửa thông tin', 'pencil', { href: './+info' }],
    ],
  }

  Object.assign(nvinfo, payload)
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props: { nvinfo }, stuff: { topbar } }
}
