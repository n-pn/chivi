<script>
  // export let segment = ''
  import { stores } from '@sapper/app'
  const { page } = stores()

  import { lookup_pinned, lookup_active } from '../stores.js'

  $: {
    if (typeof gtag === 'function') {
      window.gtag('config', 'UA-160000714-1', {
        page_path: $page.path,
      })
    }
  }

  function navigate(evt) {
    if (!evt.altKey) return

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

<svelte:window on:keydown={navigate} />

<main class:_tilt={$lookup_pinned && $lookup_active}>
  <slot />
</main>

<style lang="scss">
  main {
    &._tilt {
      // transform: translateX(-30rem);
      @include screen-min(lg) {
        // transform: none;
        margin-right: 30rem;
      }
    }
  }

  :global(.wrapper) {
    padding: 0;
    margin: 0 auto;
    width: 54rem;
    max-width: 100%;
  }
</style>
