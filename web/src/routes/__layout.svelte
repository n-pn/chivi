<script context="module">
  import { navigating, page, session } from '$app/stores'
  import { scroll, toleft, config, layers } from '$lib/stores'
</script>

<script>
  import Loader from '$molds/Loader.svelte'
  import { onMount } from 'svelte'
  import '../css/generic.scss'

  const links = [
    ['Voz.vn', 'https://voz.vn/t/truyen-tau-dich-may-mtl.95881/'],
    ['Discord', 'https://discord.gg/mdC3KQH'],
    ['Github', 'https://github.com/np-nam/chivi'],
    ['Facebook', 'https://www.facebook.com/chivi.fb/'],
  ]

  $: {
    if (typeof gtag === 'function') {
      gtag('config', 'UA-160000714-1', { page_path: $page.path })
    }
  }

  let wtheme = $session.wtheme
  $: if ($config.wtheme) wtheme = $config.wtheme

  onMount(() => {
    if (!$config.wtheme) config.put('wtheme', $session.wtheme)
  })

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
    const layer = $layers[0]
    const elem = document.querySelector(`${layer} ${sel}`)
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

<svelte:head>
  <meta name="theme-color" content="#0b476b" />
</svelte:head>

<div
  class="app tm-{wtheme} app-fs-{$config.ftsize} app-ff-{$config.ftface}"
  class:kbd-hint={kbd_hint}
  class:_shift={$toleft}>
  <slot />

  <footer>
    <div class="notes">
      <a href="/notes/changelog" class="-link">Thông tin cập nhật</a>
      <a href="/notes/donation" class="-link">Ủng hộ trang</a>
    </div>

    <div class="links">
      <strong>Links: </strong>
      {#each links as [text, href]}
        <a {href} class="-link" target="_blank" rel="noreferer noopener"
          >{text}</a>
      {/each}
    </div>
  </footer>
</div>

{#if $navigating}
  <Loader />
{/if}

<style lang="scss">
  .app {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    position: relative;

    @include bgcolor(main);
    @include fgcolor(main);

    &._shift {
      @include bps(padding-right, $ls: 30rem);
    }
  }

  footer {
    line-height: 1.25rem;
    display: flex;
    flex-wrap: wrap;
    width: 100%;
    justify-content: center;
    margin-top: auto;
    padding: var(--gutter-pl);

    @include ftsize(sm);
    @include border($loc: top);
    @include fgcolor(tert);
    @include bgcolor(tert);
  }

  .links {
    &:before {
      @include fgcolor(mute);
      margin: 0 0.5rem;
      content: '|';
    }
  }

  .-link {
    & + & {
      margin-left: 0.5rem;
    }

    font-weight: 500;

    @include fgcolor(primary, 6);

    &:hover {
      @include fgcolor(primary, 4);
    }
  }
</style>
