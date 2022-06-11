<script context="module" lang="ts">
  import { suggest_read } from '$utils/ubmemo_utils'

  export async function load({ stuff, url }) {
    const { api, nvinfo } = stuff
    let nslist = await api.nslist(nvinfo.bslug)

    const topbar = gen_topbar(nvinfo, stuff.ubmemo, url)
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
</script>

<slot />
