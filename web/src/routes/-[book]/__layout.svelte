<script context="module">
  import { page } from '$app/stores'
  import { api_call } from '$api/_api_call'
  import * as ubmemo_api from '$api/ubmemo_api'

  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ params, fetch }) {
    const [status, stuff] = await api_call(fetch, `books/${params.book}`)

    if (status) return { status, error: stuff }

    const { nvinfo } = stuff
    const left = [[nvinfo.vname, 'book', `/-${nvinfo.bslug}`, null, '_title']]

    appbar.set({ left, right: gen_appbar_right(nvinfo, stuff.ubmemo) })
    return { stuff }
  }

  function gen_keywords({ zname, vname, hname, author, genres }) {
    return [zname, vname, hname, author, ...genres].join(',')
  }

  function gen_appbar_right(nvinfo, ubmemo) {
    if (ubmemo.chidx == 0) return null
    const last_read = ubmemo_api.last_read(nvinfo, ubmemo)
    const right_opts = { kbd: '+', _text: '_show-lg' }

    return [[last_read.text, last_read.icon, last_read.href, right_opts]]
  }
</script>

<script>
  $: nvinfo = $page.stuff.nvinfo || {}
  $: bintro = (nvinfo.bintro || []).join('').substring(0, 300)
  $: bcover = nvinfo.bcover || '_blank.png'
  $: update = new Date(nvinfo.mftime || 0).toISOString()
  $: genres = nvinfo.genres || []
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
  <meta property="og:novel:author" content={nvinfo.author} />
  <meta property="og:novel:book_name" content={nvinfo.vname} />
  <meta property="og:novel:status" content={nvinfo.status} />
  <meta property="og:novel:update_time" content={update} />
</svelte:head>

<slot />
