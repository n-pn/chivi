<script context="module" lang="ts">
  throw new Error("@migration task: Check code was safely removed (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292722)");

  // import { page } from '$app/stores'
  // import { map_status } from '$utils/nvinfo_utils'

  // export async function load({ params, stuff, url }) {
  //   const bslug = params.book

  //   const res = await stuff.api.nvbook(bslug)
  //   if (!res.error) return { props: res, stuff: res }
  //   if (res.status != 301) return res

  //   const redirect = url.pathname.replace(bslug, res.error).trim()
  //   return { status: 301, redirect: encodeURI(redirect) }
  // }

  // function gen_keywords(nvinfo: CV.Nvinfo) {
  //   const kw = [
  //     nvinfo.btitle_zh,
  //     nvinfo.btitle_vi,
  //     nvinfo.btitle_hv,
  //     nvinfo.author_zh,
  //     nvinfo.author_vi,
  //     ...nvinfo.genres,
  //   ]
  //   return kw.filter((v, i, a) => i != a.indexOf(v)).join(',')
  // }
</script>

<script lang="ts">
  throw new Error("@migration task: Add data prop (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292707)");

  import { dtlist_data } from '$lib/stores'
  import { setContext } from 'svelte'
  import { writable } from 'svelte/store'

  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo

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

  $: setContext('ubmemos', writable($page.stuff.ubmemo))
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
