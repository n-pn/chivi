<script context="module" lang="ts">
  import { map_status } from '$utils/nvinfo_utils'

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

  $: ({ nvinfo } = data)

  $: bcover = nvinfo.bcover || 'blank.webp'
  $: bintro = nvinfo.bintro.substring(0, 300)
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
</script>

<svelte:head>
  <title>{nvinfo.btitle_vi} - Chivi</title>
  <meta name="keywords" content={gen_keywords(nvinfo)} />
  <meta name="description" content={bintro} />

  <meta property="og:title" content={nvinfo.btitle_vi} />
  <meta property="og:type" content="novel" />
  <meta property="og:description" content={bintro} />
  <meta property="og:url" content="https://chivi.app/-{nvinfo.bslug}" />
  <meta property="og:image" content="https://r2.chivi.app/covers/{bcover}" />

  <meta property="og:novel:category" content={genres[0]} />
  <meta property="og:novel:author" content={nvinfo.author_vi} />
  <meta property="og:novel:book_name" content={nvinfo.btitle_vi} />
  <meta property="og:novel:status" content={map_status(nvinfo.status)} />
  <meta property="og:novel:update_time" content={update} />
</svelte:head>

<slot />
