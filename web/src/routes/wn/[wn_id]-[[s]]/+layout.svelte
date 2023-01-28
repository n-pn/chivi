<script context="module" lang="ts">
  import { map_status } from '$utils/nvinfo_utils'
  import { vdict } from '$lib/stores'

  function gen_keywords(nvinfo: CV.Nvinfo) {
    const kw = [
      nvinfo.btitle_zh,
      nvinfo.btitle_vi,
      nvinfo.btitle_hv,
      nvinfo.author_zh,
      nvinfo.author_vi,
      ...nvinfo.genres,
    ]
    return kw.filter((v, i, a) => i != a.indexOf(v)).join(',')
  }
</script>

<script lang="ts">
  import { dtlist_data } from '$lib/stores'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: nvinfo = data.nvinfo
  $: bcover = nvinfo.bcover || 'blank.webp'
  $: update = new Date(nvinfo.mftime || 0).toISOString()
  $: genres = nvinfo.genres || []

  $: dtlist_data.update((x) => {
    x.tab = 'book'
    x.book = {
      id: nvinfo.id,
      bname: nvinfo.btitle_vi,
      bslug: nvinfo.bslug,
    }
    return x
  })

  $: vdict.set({
    dname: '-' + nvinfo.bhash,
    d_dub: nvinfo.btitle_vi,
    d_tip: `Từ điển riêng cho bộ truyện: ${nvinfo.btitle_vi}`,
  })
</script>

<svelte:head>
  <meta name="keywords" content={gen_keywords(nvinfo)} />

  <meta property="og:type" content="novel" />
  <meta property="og:url" content="https://chivi.app/wn/{nvinfo.bslug}" />
  <meta property="og:image" content="https://cr2.chivi.app/covers/{bcover}" />

  <meta property="og:novel:category" content={genres[0]} />
  <meta property="og:novel:author" content={nvinfo.author_vi} />
  <meta property="og:novel:book_name" content={nvinfo.btitle_vi} />
  <meta property="og:novel:status" content={map_status(nvinfo.status)} />
  <meta property="og:novel:update_time" content={update} />
</svelte:head>

<slot />
