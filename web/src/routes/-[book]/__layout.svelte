<script context="module">
  import { api_call } from '$api/_api_call'

  export async function load({ page: { params }, fetch }) {
    const [status, props] = await api_call(fetch, `books/${params.book}`)
    return status ? { status, error: props } : { stuff: props, props }
  }
</script>

<script>
  export let nvinfo

  function keywords({ zname, vname, hname, author, genres }) {
    return [zname, vname, hname, author, ...genres].join(',')
  }

  $: book_intro = nvinfo.bintro.join('').substring(0, 300)
</script>

<!-- prettier-ignore -->
<svelte:head>
  <title>{nvinfo.vname} - Chivi</title>
  <meta name="keywords" content={keywords(nvinfo)} />
  <meta name="description" content={book_intro} />

  <meta property="og:title" content={nvinfo.vname} />
  <meta property="og:type" content="novel" />
  <meta property="og:description" content={book_intro} />
  <meta property="og:url" content="https://chivi.app/-{nvinfo.bslug}" />
  <meta property="og:image" content="https://chivi.app/covers/{nvinfo.bcover}" />

  <meta property="og:novel:category" content={nvinfo.genres[0]} />
  <meta property="og:novel:author" content={nvinfo.author} />
  <meta property="og:novel:book_name" content={nvinfo.vname} />
  <meta property="og:novel:status" content={nvinfo.status} />
  <meta property="og:novel:update_time" content={new Date(nvinfo.mftime).toISOString()} />
</svelte:head>

<slot />
