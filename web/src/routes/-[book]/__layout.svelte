<script context="module" lang="ts">
  import { page } from '$app/stores'

  export async function load({ params, fetch }) {
    const res = await fetch(`/api/books/${params.book}`)
    const data = await res.json()
    if (res.ok) data.stuff = data.props
    return data
  }

  function gen_keywords({ zname, vname, hname, author, genres }) {
    return [zname, vname, hname, author, ...genres].join(',')
  }
</script>

<script lang="ts">
  export let nvinfo = $page.stuff.nvinfo

  let bintro = nvinfo.bintro.join('').substring(0, 300)
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
