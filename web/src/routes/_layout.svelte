<script>
  // export let segment = ''
  import { stores } from '@sapper/app'
  const { page } = stores()

  import Wrapper from '$mould/layout/Wrapper.svelte'

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
    // padding-top: 3rem;
    &.tilt {
      margin-right: 30rem;
    }
  }
</style>

<svelte:window on:keydown={navigate} />

<main class="tilt">
  <slot />
</main>
