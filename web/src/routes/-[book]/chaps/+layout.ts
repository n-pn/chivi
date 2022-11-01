import { suggest_read } from '$utils/ubmemo_utils'

throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ stuff, url }) {
  const { api, nvinfo } = stuff
  let nslist = await api.nslist(nvinfo.id)

  const topbar = gen_topbar(nvinfo, stuff.ubmemo, url)
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return nslist.error ? nslist : { stuff: { nslist, topbar } }
}

function gen_topbar(nvinfo: CV.Nvinfo, ubmemo: CV.Ubmemo, { pathname }) {
  const { btitle_vi, bslug } = nvinfo
  return {
    left: [
      [btitle_vi, 'book', { href: `/-${bslug}`, show: 'tm', kind: 'title' }],
      ['Chương tiết', 'list', { href: pathname, show: 'pm' }],
    ],
    right: [suggest_read(nvinfo, ubmemo)],
  }
}
