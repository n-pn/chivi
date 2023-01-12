<script>
  import { afterNavigate } from '$app/navigation'

  afterNavigate(({ from: { url } }) => {
    if (!url.pathname.startsWith('/_auth')) {
      const back = url.toString()
      sessionStorage.setItem('back', back.includes('_auth') ? '/' : back)
    }
  })
</script>

<div class="wrap">
  <header class="brand">
    <img src="/icons/chivi.svg" alt="logo" />
    <span class="-text">Chivi</span>
  </header>

  <article class="article island">
    <slot />
  </article>
</div>

<style lang="scss">
  .wrap {
    @include flex-ca;
    flex-direction: column;
    flex: 1;
    margin-bottom: var(--gutter);
  }

  .brand {
    // font-weight: 300;
    line-height: 2.5rem;
    padding-bottom: 0.75rem;
    padding-right: 0.75rem;

    @include flex-ca;

    > .-text {
      margin-left: 0.5rem;
      @include ftsize(x3);
    }
  }

  article {
    width: 100%;
    max-width: 25rem;
  }
</style>
