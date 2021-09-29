<script>
  import { navigating, page, session } from '$app/stores'
  import { scroll } from '$lib/stores'
  import Loader from '$molds/Loader.svelte'

  import '../css/generic.scss'

  const links = [
    ['Vozforums', 'https://voz.vn/t/truyen-tau-dich-may-mtl.95881/'],
    ['Facebook', 'https://www.facebook.com/chivi.fb/'],
    ['Telegram', 'https://t.me/chivi_support'],
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
      $scroll = 0
      return
    }

    const scrollTop = window.pageYOffset || document.documentElement.scrollTop
    $scroll = scrollTop - prevScrollTop
    prevScrollTop = scrollTop <= 0 ? 0 : scrollTop
  }

  // function disable_router_unless_vip(e) {
  //   // disabled until adsense is unblocked
  //   if ($session.privi < 2) e.stopPropagation()
  // }

  let kbd_hint = false

  function handle_keydown(evt) {
    switch (evt.key) {
      case 'Enter':
        if (evt.ctrlKey) trigger_click(evt, `[data-kbd="⌃↵"]`)
        else if (evt.shiftKey) trigger_click(evt, `[data-kbd="⇧↵"]`)
        else trigger_click(evt, `[data-kbd="↵"]`)
        return
      case 'Escape':
        trigger_click(evt, `[data-kbd="esc"]`)
        return

      default:
        if (evt.ctrlKey) return
    }

    let active = document?.activeElement
    switch (active?.tagName) {
      case 'TEXTAREA':
      case 'INPUT':
        if (!evt.altKey) return
    }

    if (evt.key == 'Shift') kbd_hint = true

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
</script>

<svelte:window
  on:scroll={handle_scroll}
  on:keydown={handle_keydown}
  on:keyup={() => (kbd_hint = false)} />

<div class="app tm-{$session.wtheme}" class:kbd-hint={kbd_hint}>
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
    @include border($loc: top);
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
