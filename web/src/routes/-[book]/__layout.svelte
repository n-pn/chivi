<script context="module" lang="ts">
  import { page } from '$app/stores'
  import { map_status } from '$utils/nvinfo_utils'

  import { wrap_get } from '$lib/api_call'

  export async function load({ params, fetch, url }) {
    const slug = params.book

    const api_url = `/api/books/${slug}`
    const api_res = await wrap_get(fetch, api_url)

    if (api_res.status < 300) {
      api_res['stuff'] = api_res.props
    } else if (api_res.status == 301) {
      const redirect = url.pathname.replace(slug, api_res.redirect)
      console.log(redirect)
      api_res.redirect = encodeURI(redirect)
    }

    return api_res
  }

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

  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo

  $: bintro = nvinfo.bintro.substring(0, 300)
  $: bcover = nvinfo.bcover ? `/covers/${nvinfo.bcover}` : '/imgs/empty.png'
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
  <meta property="og:image" content="https://chivi.app/{bcover}" />

  <meta property="og:novel:category" content={genres[0]} />
  <meta property="og:novel:author" content={nvinfo.author_vi} />
  <meta property="og:novel:book_name" content={nvinfo.btitle_vi} />
  <meta property="og:novel:status" content={map_status(nvinfo.status)} />
  <meta property="og:novel:update_time" content={update} />
</svelte:head>

<slot />
