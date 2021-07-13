<script>
  import { navigating, page, session } from '$app/stores'
  import { l_scroll } from '$lib/stores'
  import Loader from '$molds/Loader.svelte'

  import '../css/generic.scss'

  const links = [
    ['Vozforums', 'https://voz.vn/t/truyen-tau-dich-may-mtl.95881/'],
    ['Facebook', 'https://www.facebook.com/chivi.xyz/'],
    ['Telegram', 'https://t.me/chivi_xyz'],
    ['Discord', 'https://discord.gg/mdC3KQH'],
    ['Github', 'https://github.com/np-nam/chivi'],
  ]

  $: {
    if (typeof gtag === 'function') {
      window.gtag('config', 'UA-160000714-1', {
        page_path: $page.path,
      })
    }
  }

  let prevScrollTop = 0

  function track_scrolling() {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop
    $l_scroll = scrollTop - prevScrollTop
    prevScrollTop = scrollTop <= 0 ? 0 : scrollTop
  }

  // function disable_router_unless_vip(e) {
  //   // disabled until adsense is unblocked
  //   if ($session.privi < 2) e.stopPropagation()
  // }
</script>

<svelte:head>
  {#if $session.privi < 2}
    <script
      async
      data-ad-client="ca-pub-5468438393284967"
      src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
  {/if}
</svelte:head>

<svelte:window on:scroll={track_scrolling} />

<div class="app" class:tm-dark={$session.site_theme == 'dark'}>
  <slot />

  <div class="links">
    <span> Liên kết: </span>

    {#each links as [text, href]}
      <a {href} class="-link" target="_blank" rel="noreferer noopener"
        >{text}</a>
    {/each}
  </div>
</div>

<Loader active={$navigating} />

<style lang="scss">
  :global(#svelte) {
    display: flex;
    flex-direction: column;
    min-height: 100%;
  }

  .app {
    height: 100%;
    @include bgcolor(main);
    @include fgcolor(main);
  }

  .links {
    width: 100%;
    text-align: center;
    padding: 0.75rem;

    @include ftsize(sm);
    @include border($sides: top);
    @include fgcolor(neutral, 6);
    @include bgcolor(neutral, 2);

    @include tm-dark {
      @include fgcolor(neutral, 4);
      @include bgcolor(neutral, 8);
      @include bdcolor(neutral, 7);
    }
  }

  .-link {
    margin-left: 0.375rem;
    font-weight: 500;

    @include fgcolor(primary, 6);

    &:hover {
      @include fgcolor(primary, 4);
    }
  }
</style>
