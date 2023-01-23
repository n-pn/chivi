import { set_fetch, api_get } from '$lib/api_call'

export async function load({ parent, fetch, params }) {
  const { nvinfo, nvseed } = await parent()
  const { sname } = nvseed

  const chidx = params.chidx.split('-', 2)[0]

  set_fetch(fetch)

  // TODO: call `api_path` to generate path
  const path = `/_db/texts/${nvinfo.id}/${sname}/${chidx}`
  const { title, chvol, input } = await api_get(path)

  const dname = '-' + nvinfo.bhash
  const _meta = page_meta(nvinfo, sname, chidx)

  return { title, chvol, input, chidx, sname, dname, _meta }
}

function page_meta({ bslug, btitle_vi }, sname: string, chidx: number) {
  const chap_href = `/-${bslug}/chaps/${sname}`
  return {
    title: `Sửa text gốc chương #${chidx} - ${btitle_vi}`,
    left_nav: [
      // prettier-ignore
      { text: sname, icon: 'list', href: chap_href, 'data-show': 'ts', 'data-kind': 'zseed' },
      { text: `#${chidx}`, icon: 'edit', href: `${chap_href}/${chidx}` },
    ],
  }
}
