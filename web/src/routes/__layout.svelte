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

  function handle_scroll() {
    if ($navigating == true) {
      prevScrollTop = 0
      $l_scroll = 0
      return
    }

    const scrollTop = window.pageYOffset || document.documentElement.scrollTop
    $l_scroll = scrollTop - prevScrollTop
    prevScrollTop = scrollTop <= 0 ? 0 : scrollTop
  }

  // function disable_router_unless_vip(e) {
  //   // disabled until adsense is unblocked
  //   if ($session.privi < 2) e.stopPropagation()
  // }

  function handle_keydown(evt) {
    switch (evt.key) {
      case 'Enter':
        if (evt.ctrlKey) trigger_click(evt, `[data-kbd="ctrl+enter"]`)
        return
      case 'Escape':
        trigger_click(evt, `[data-kbd="esc"]`)
        return

      default:
        if (evt.ctrlKey) return
    }

    if (evt.key == 'Shift') {
      return (kbd_hint = !kbd_hint)
    }

    let active = document?.activeElement
    switch (active?.tagName) {
      case 'TEXTAREA':
      case 'INPUT':
        if (!evt.altKey) return
    }

    if (evt.key == '"') {
      trigger_click(evt, `[data-kbd='"']`)
    } else {
      trigger_click(evt, `[data-kbd="${evt.key}"]`)
      trigger_click(evt, `[data-key="${evt.keyCode}"]`)
    }
  }

  function trigger_click(evt, sel) {
    const elem = document.querySelector(sel)
    if (!elem) return
    evt.preventDefault()
    evt.stopPropagation()
    elem.click()
  }

  let kbd_hint = false
</script>

<svelte:head>
  {#if $session.privi < 2}
    <script
      async
      data-ad-client="ca-pub-5468438393284967"
      src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
  {/if}
</svelte:head>

<svelte:window on:scroll={handle_scroll} on:keydown={handle_keydown} />

<div
  class="app"
  class:tm-dark={$session.site_theme == 'dark'}
  class:kbd-hint={kbd_hint}>
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
  .app {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    position: relative;

    @include bgcolor(main);
    @include fgcolor(main);
  }

  .links {
    width: 100%;
    margin-top: auto;
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
