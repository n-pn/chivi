<script>
  export let segment = ''
  import { stores } from '@sapper/app'
  const { page } = stores()

  $: {
    if (typeof gtag === 'function') {
      window.gtag('config', 'UA-160000714-1', {
        page_path: $page.path,
      })
    }
  }

  function navigate(evt) {
    switch (evt.keyCode) {
      case 72:
        _goto('/')
        evt.preventDefault()
        break

      default:
        break
    }
  }
</script>

<style lang="scss">
  $header-height: 3rem;
  header {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: $header-height;
    z-index: 999;
    background-color: #fff;
    // @include bgcolor(primary, 6);
    @include shadow(3);
  }
  main {
    padding-top: $header-height;
  }
  .wrap {
    margin: 0 auto;
    width: 50rem;
    max-width: 100%;

    padding: 0 0.75rem;

    @include screen-min(md) {
      padding: 0 1rem;
    }

    @include screen-min(lg) {
      padding: 0 1.25rem;
    }

    @include screen-min(xl) {
      padding: 0 1.5rem;
    }
  }
  .logo {
    display: inline-block;
    text-decoration: none;

    $height: 2.25rem;
    $gutter: ($header-height - $height) / 2;
    margin: $gutter 0;
    height: $height;
    line-height: $height;
    padding: 0 0.5rem;
    text-transform: uppercase;

    // font-variant: small-caps;
    @include color(primary, 9);
    font-weight: 500;
    letter-spacing: 0.1em;
    @include radius();
    @include font-size(2);
    @include bgcolor(primary, 1);

    @include hover() {
      @include bgcolor(primary, 5);
      color: #fff;
    }

    > img {
      display: inline-block;
      margin-top: -0.125rem;
      width: 1.25rem;
      height: 1.25rem;
    }
  }
</style>

<svelte:head>
  <script
    async
    src="https://www.googletagmanager.com/gtag/js?id=UA-160000714-1">

  </script>
  <script>
    window.dataLayer = window.dataLayer || []
    function gtag() {
      dataLayer.push(arguments)
    }
    gtag('js', new Date())
    gtag('config', 'UA-160000714-1')
  </script>
</svelte:head>

<svelte:window on:keydown={navigate} />

<header>
  <div class="wrap">
    <a href="/" class="logo" class:_active={segment == null}>
      <img src="/logo.svg" alt="logo" />
      <span>Chivi</span>
    </a>
  </div>
</header>
<main>
  <div class="wrap">
    <slot />
  </div>
</main>
