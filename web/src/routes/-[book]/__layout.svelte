<script context="module" lang="ts">
  import { page } from '$app/stores'
  import { map_status } from '$utils/nvinfo_utils'

  export async function load({ params, fetch }) {
    const res = await fetch(`/api/books/${params.book}`)
    const data = await res.json()
    if (res.ok) data.stuff = data.props
    return data
  }

  function gen_keywords(nvinfo: CV.Nvinfo) {
    const kw = [
      nvinfo.zname,
      nvinfo.vname,
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

  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo

  $: bintro = nvinfo.bintro.substring(0, 300)
  $: bcover = nvinfo.bcover || '_blank.png'
  $: update = new Date(nvinfo.mftime || 0).toISOString()
  $: genres = nvinfo.genres || []

  $: dtlist_data.update((x) => {
    x.tab = 'book'
    x.book = {
      id: nvinfo.id,
      bname: nvinfo.vname,
      bslug: nvinfo.bslug,
    }
    return x
  })
</script>

<svelte:head>
  <title>{nvinfo.vname} - Chivi</title>
  <meta name="keywords" content={gen_keywords(nvinfo)} />
  <meta name="description" content={bintro} />

  <meta property="og:title" content={nvinfo.vname} />
  <meta property="og:type" content="novel" />
  <meta property="og:description" content={bintro} />
  <meta property="og:url" content="https://chivi.app/-{nvinfo.bslug}" />
  <meta property="og:image" content="https://chivi.app/covers/{bcover}" />

  <meta property="og:novel:category" content={genres[0]} />
  <meta property="og:novel:author" content={nvinfo.author_vi} />
  <meta property="og:novel:book_name" content={nvinfo.vname} />
  <meta property="og:novel:status" content={map_status(nvinfo.status)} />
  <meta property="og:novel:update_time" content={update} />
</svelte:head>

<slot />
