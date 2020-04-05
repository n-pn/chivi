<script>
  import Wrapper from './Wrapper.svelte'
  import LinkBtn from './header/LinkBtn.svelte'
  import IconBtn from './header/IconBtn.svelte'

  let header
  let scroll = 0

  function scrolling(evt) {
    const st = window.pageYOffset || document.documentElement.scrollTop
    if (st > scroll) {
      header.classList.remove('fixed')
    } else {
      header.classList.add('fixed')
    }
    scroll = st <= 0 ? 0 : st
  }
</script>

<style lang="scss">
  $outer-height: 3rem;

  $inner-height: 2.25rem;
  $gutter: ($outer-height - $inner-height) / 2;

  header {
    position: sticky;
    top: 0;
    left: 0;
    width: 100%;
    height: $outer-height;
    z-index: 800;
    @include bgcolor(primary, 6);
    @include shadow(2);

    :global(&.fixed) {
      // position: fixed;
    }
  }
  nav {
    display: flex;
    padding: $gutter 0.75rem;
    line-height: $inner-height;
    color: #fff;

    :global(.left) {
      display: flex;
      margin-right: auto;
    }

    :global(.right) {
      display: flex;
      margin-left: auto;
    }
  }
</style>

<svelte:window on:scroll={scrolling} />

<header bind:this={header}>
  <Wrapper>
    <nav>
      <slot>
        <div class="left">
          <LinkBtn href="/" class="logo active">
            <img src="/logo.svg" alt="logo" />
            <span>Chivi</span>
          </LinkBtn>
        </div>
      </slot>
    </nav>
  </Wrapper>
</header>
