<script context="module" lang="ts">
  import { map_status } from '$utils/nvinfo_utils'
  import { vdict } from '$lib/stores'

  function gen_keywords(nvinfo: CV.Wninfo) {
    const kw = [
      nvinfo.ztitle,
      nvinfo.vtitle,
      nvinfo.htitle,
      nvinfo.zauthor,
      nvinfo.vauthor,
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
  $: genres = nvinfo.genres || []

  $: update = new Date(nvinfo.mftime || 0).toISOString()

  $: dtlist_data.update((x) => {
    x.tab = 'book'
    x.book = {
      id: nvinfo.id,
      bname: nvinfo.vtitle,
      bslug: nvinfo.bslug,
    }

    return x
  })

  $: vdict.put(nvinfo.id, nvinfo.vtitle)
</script>

<svelte:head>
  <meta name="keywords" content={gen_keywords(nvinfo)} />

  <meta property="og:type" content="novel" />
  <meta property="og:novel:category" content={genres[0]} />
  <meta property="og:novel:author" content={nvinfo.vauthor} />
  <meta property="og:novel:book_name" content={nvinfo.vtitle} />
  <meta property="og:novel:status" content={map_status(nvinfo.status)} />
  <meta property="og:novel:update_time" content={update} />
</svelte:head>

<slot />
