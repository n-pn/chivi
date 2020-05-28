<script>
  export let segment = ''
  import { stores } from '@sapper/app'
  const { page } = stores()

  const font_href =
    'https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,300;0,400;0,500;1,300;1,400&display=swap'

  const google_ad = 'UA-160000714-1'
  $: {
    if (typeof gtag === 'function') {
      window.gtag('config', google_ad, {
        page_path: $page.path,
      })
    }
  }
</script>

<slot {segment} />

<svelte:head>
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link rel="preload" as="style" href={font_href} />
  <link
    rel="stylesheet"
    href={font_href}
    media="print"
    onload="this.media='all'" />
  <noscript>
    <link rel="stylesheet" href={font_href} />
  </noscript>

  <script async src="https://www.googletagmanager.com/gtag/js?id={google_ad}">

  </script>
  <script>
    window.dataLayer = window.dataLayer || []
    function gtag() {
      dataLayer.push(arguments)
    }
    gtag('js', new Date())
    gtag('config', google_ad)
  </script>
</svelte:head>
