<script>
  // export let segment = ''
  import { stores } from '@sapper/app'
  const { page } = stores()

  import { lookup_pinned } from '../stores.js'

  $: {
    if (typeof gtag === 'function') {
      window.gtag('config', 'UA-160000714-1', {
        page_path: $page.path,
      })
    }
  }

  function navigate(evt) {
    if (evt.ctrlKey || evt.altKey || evt.shiftKey) return

    switch (evt.keyCode) {
      case 73:
        _goto('/')
        evt.preventDefault()
        break

      default:
        break
    }
  }
</script>

<style lang="scss">
  main {
    &._tilt {
      margin-right: 30rem;
    }
  }

  :global(.wrapper) {
    padding: 0;
    margin: 0 auto;
    width: 54rem;
    max-width: 100%;
  }
</style>

<svelte:window on:keydown={navigate} />

<main class:_tilt={$lookup_pinned}>
  <slot />
</main>
