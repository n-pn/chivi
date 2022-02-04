<script context="module">
  import { navigating, page, session } from '$app/stores'
  import { beforeNavigate } from '$app/navigation'
  import { scroll, toleft, config, layers } from '$lib/stores'
</script>

<script>
  import Appbar from '$sects/Appbar.svelte'
  import Loader from '$molds/Loader.svelte'
  import { onMount } from 'svelte'
  import '../css/generic.scss'

  const links = [
    ['Discord', 'https://discord.gg/mdC3KQH'],
    ['Github', 'https://github.com/np-nam/chivi'],
    ['Facebook', 'https://www.facebook.com/chivi.fb/'],
  ]

  $: {
    if (typeof gtag === 'function') {
      gtag('config', 'UA-160000714-1', { page_path: $page.url.pathname })
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

  function map_key(evt, key) {
    if (evt.shiftKey) key = '⇧' + key
    if (evt.ctrlKey) key = '⌃' + key

    return key
  }

  function handle_keydown(evt) {
    switch (evt.key) {
      case 'Enter':
        return trigger_click(evt, `[data-kbd="${map_key(evt, '↵')}"]`)

      case 'Escape':
        return trigger_click(evt, `[data-kbd="esc"]`)

      case 'ArrowLeft':
        if (!evt.altKey) return
        return trigger_click(evt, `[data-kbd="${map_key(evt, '←')}"]`)

      case 'ArrowRight':
        if (!evt.altKey) return
        return trigger_click(evt, `[data-kbd="${map_key(evt, '→')}"]`)

      case 'ArrowUp':
        if (!evt.altKey) return
        return trigger_click(evt, `[data-kbd="${map_key(evt, '↑')}"]`)

      case 'ArrowDown':
        if (!evt.altKey) return
        return trigger_click(evt, `[data-kbd="${map_key(evt, '↓')}"]`)

      default:
        if (evt.ctrlKey) return
    }

    switch (document.activeElement?.tagName) {
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

  // force hard refresh after number of click

  let counter = 0

  beforeNavigate(({ from, to, cancel }) => {
    console.log(from, to, counter)

    counter += 1
    switch ($session.privi) {
      case -1:
      case 0:
        if (counter < 1) return
      case 1:
        if (counter < 6) return
      default:
        if (counter < 18) return
    }

    cancel()
  })
</script>

<svelte:head>
  {#if $session.privi < 2}
    <script
      async
      src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-5468438393284967"
      crossorigin="anonymous"></script>
  {/if}
</svelte:head>

<svelte:window
  on:scroll={handle_scroll}
  on:keydown={handle_keydown}
  on:keyup={() => (kbd_hint = false)} />

<div
  class="app tm-{wtheme} app-fs-{$config.ftsize} app-ff-{$config.ftface}"
  class:kbd-hint={kbd_hint}
  class:_shift={$toleft}>
  <Appbar />

  <main class="main">
    <div class="vessel">
      {#if $session.privi < 0}
        <div class="pledge">
          Protip: Đăng ký tài khoản <strong>Chivi</strong> ngay hôm nay để mở khoá
          các tính năng!
        </div>
      {:else if $session.privi < 2}
        <a class="pledge" href="/guide/donation">
          Ủng hộ <strong>Chivi</strong> để nâng cấp quyền hạn!
        </a>
      {/if}

      <a
        href="/forum/-thong-bao/-thong-bao-ve-viec-thay-doi-co-che-hfj4"
        class="pledge">
        Thông báo về việc thay đổi cơ chế quyền hạn [31-01-2022]
      </a>

      <slot />
    </div>
  </main>

  <footer>
    {counter}
    <div class="notes">
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

  $page-width: 56rem;

  :global(.vessel) {
    width: $page-width;
    max-width: 100%;
    margin: 0 auto;

    > :global(*) {
      padding: 0 var(--gutter);
    }
  }

  // $footer-height: 3.5rem;

  .main {
    flex: 1;
    position: relative;
  }

  .pledge {
    display: block;
    text-align: vessel;
    margin: 0.75rem var(--gutter);
    // max-width: 50vw;
    font-size: rem(15px);
    text-align: center;
    line-height: 1.25rem;

    padding: 0.5rem var(--gutter);

    @include fgcolor(tert);
    @include bgcolor(tert);

    @include bdradi();
  }

  a.pledge {
    &:hover {
      @include fgcolor(primary, 5);
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
