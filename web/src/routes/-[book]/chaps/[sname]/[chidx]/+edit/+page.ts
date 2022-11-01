/** @type {import('./[slug]').PageLoad} */
throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ stuff, params }) {
  const { api, nvinfo, nvseed } = stuff
  const { sname } = nvseed

  const chidx = params.chidx.split('-', 2)[0]

  const api_url = `/api/texts/${nvinfo.id}/${sname}/${chidx}`
  const api_res = await api.call(api_url, 'GET')

  if (api_res.error) throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return api_res

  const props = { nvinfo, chidx, sname, ...api_res }
  const topbar = gen_topbar(nvinfo, sname, chidx)

  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props, stuff: { topbar } }
}

function gen_topbar({ bslug, btitle_vi }, sname: string, chidx: number) {
  const chap_href = `/-${bslug}/chaps/${sname}`
  return {
    left: [
      [btitle_vi, 'book', { href: `/-${bslug}`, kind: 'title', show: 'tm' }],
      [sname, 'list', { href: chap_href, show: 'ts', kind: 'zseed' }],
      [`#${chidx}`, 'edit', { href: `${chap_href}/${chidx}` }],
    ],
  }
}
