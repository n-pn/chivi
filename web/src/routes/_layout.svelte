<script>
  import { onMount } from 'svelte'
  import { stores } from '@sapper/app'
  const { page } = stores()

  export let segment = ''

  $: {
    if (typeof gtag === 'function') {
      window.gtag('config', 'UA-160000714-1', {
        page_path: $page.path,
      })
    }
  }

  import { user, layout_shift, layout_clear } from '$src/stores'

  let lastScrollTop = 0

  // Credits: "https://github.com/qeremy/so/blob/master/so.dom.js#L426"
  function handleScroll(evt) {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop

    const scrollDown = scrollTop > lastScrollTop
    lastScrollTop = scrollTop <= 0 ? 0 : scrollTop

    $layout_clear = scrollDown
  }

  onMount(async () => {
    const res = await fetch('_self')
    const data = await res.json()
    if (data.status == 'ok') {
      $user = { uname: data.uname, power: data.power }
    } else {
      $user = { uname: 'Khách', power: -1 }
    }
  })
</script>

<style lang="scss">
  :global(html),
  :global(body) {
    min-height: 100%;
  }

  :global(#sapper) {
    position: relative;
    min-width: 320px;
    height: 100%;
  }

  $page-width: 54rem;

  :global(.wrapper) {
    width: $page-width;
    max-width: 100%;
    margin: 0 auto;
    padding: 0 0.75rem;
  }

  main {
    // width: 100%;
    // height: 100%;

    &._shift {
      @include screen-min(lg) {
        margin-right: 30rem;
      }
    }
  }
</style>

<svelte:window on:scroll={handleScroll} />

<main class:_shift={$layout_shift} class:__clear={$layout_clear}>
  <slot {segment} />
</main>
