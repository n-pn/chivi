import { api_get } from '$lib/api_call'

type ZtextRaw = { ztext: string; title: string; chdiv: string }

export async function load({ fetch, parent, params: { wn_id, sname, ch_no } }) {
  const api_url = `/_wn/texts/${wn_id}/${sname}/${ch_no}`

  const { ztext, title, chdiv } = await api_get<ZtextRaw>(api_url, fetch)

  const { nvinfo } = await parent()
  const dname = '-' + nvinfo.bhash
  const _meta = page_meta(nvinfo, sname, ch_no)

  return { ztext, title, chdiv, ch_no, wn_id, sname, dname, _meta }
}

function page_meta({ bslug, btitle_vi }, sname: string, chidx: number) {
  const chap_href = `/wn/${bslug}/chaps/${sname}`
  return {
    title: `Sửa text gốc chương #${chidx} - ${btitle_vi}`,
    left_nav: [
      // prettier-ignore
      { text: sname, icon: 'list', href: chap_href, 'data-show': 'ts', 'data-kind': 'zseed' },
      { text: `#${chidx}`, icon: 'edit', href: `${chap_href}/${chidx}` },
    ],
  }
}
