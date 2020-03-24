<script>
  import Nav from '../components/Nav.svelte'

  export let segment

  import { stores } from '@sapper/app'
  const { page } = stores()

  $: {
    if (typeof gtag === 'function') {
      window.gtag('config', 'UA-XXX', {
        page_path: $page.path,
      })
    }
  }
</script>

<style lang="scss">
  main {
    position: relative;
    max-width: 56em;
    padding: 2em;
    margin: 0 auto;
    box-sizing: border-box;
  }
</style>

<svelte:head>
  <script async src="https://www.googletagmanager.com/gtag/js?id=UA-XXX">

  </script>
  <script>
    window.dataLayer = window.dataLayer || []
    function gtag() {
      dataLayer.push(arguments)
    }
    gtag('js', new Date())
    gtag('config', 'UA-XXX')
  </script>
</svelte:head>

<Nav {segment} />

<main>
  <slot />
</main>
