<script context="module">
  import { api_call } from '$api/_api_call'

  export async function load({ page: { params }, fetch }) {
    const [status, context] = await api_call(fetch, `books/${params.book}`)
    return status ? { status, error: context } : { context, props: context }
  }
</script>

<script>
  export let cvbook

  function gen_keywords(cvbook) {
    // prettier-ignore
    const list = [
      cvbook.ztitle, cvbook.vtitle, cvbook.htitle,
      cvbook.zauthor, cvbook.vauthor, ...cvbook.genres,
      'Truyện tàu', 'Truyện convert', 'Truyện mạng' ]
    return list.join(',')
  }

  $: book_intro = cvbook.bintro.join('').substring(0, 300)
</script>

<!-- prettier-ignore -->
<svelte:head>
  <title>{cvbook.vtitle} - Chivi</title>
  <meta name="keywords" content={gen_keywords(cvbook)} />
  <meta name="description" content={book_intro} />

  <meta property="og:title" content={cvbook.vtitle} />
  <meta property="og:type" content="novel" />
  <meta property="og:description" content={book_intro} />
  <meta property="og:url" content="https://chivi.app/-{cvbook.bslug}" />
  <meta property="og:image" content="https://chivi.app/covers/{cvbook.bcover}" />

  <meta property="og:novel:category" content={cvbook.genres[0]} />
  <meta property="og:novel:author" content={cvbook.vauthor} />
  <meta property="og:novel:book_name" content={cvbook.vtitle} />
  <meta property="og:novel:status" content={cvbook.status} />
  <meta property="og:novel:update_time" content={new Date(cvbook.mftime).toISOString()} />
</svelte:head>

<slot />
