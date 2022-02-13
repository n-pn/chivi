<script context="module" lang="ts">
  import { navigating, page, session } from '$app/stores'
  import { beforeNavigate } from '$app/navigation'
  import { scroll, toleft, config, layers } from '$lib/stores'
  declare var gtag: any

  const links = [
    ['Discord', 'https://discord.gg/mdC3KQH'],
    ['Github', 'https://github.com/np-nam/chivi'],
    ['Facebook', 'https://www.facebook.com/chivi.fb/'],
  ]
</script>

<script lang="ts">
  import { map_keypress, trigger_click } from '$utils/kbd_utils'

  import Pledge from '$gui/sects/layout/Pledge.svelte'
  import Loader from '$gui/sects/layout/Loader.svelte'
  import Appbar from '$gui/sects/layout/Appbar.svelte'

  import '../styles/generic.scss'

  $: {
    if (typeof gtag === 'function') {
      gtag('config', 'UA-160000714-1', { page_path: $page.url.pathname })
    }
  }

  let wtheme = $session.wtheme || 'oled'
  $: {
    if ($config.wtheme) wtheme = $config.wtheme
    else config.put('wtheme', wtheme)
  }

  let kbd_hint = false

  function handle_keydown(evt: KeyboardEvent) {
    if (evt.key == 'Shift') return (kbd_hint = true)

    let kbd = map_keypress(evt)
    if (!kbd) return

    const scope = $layers[0]
    if (evt.key == '"') {
      trigger_click(evt, `${scope} [data-kbd='${kbd}']`)
    } else {
      trigger_click(evt, `${scope} [data-kbd="${kbd}"]`)
      trigger_click(evt, `${scope} [data-key="${evt.code}"]`)
    }
  }

  beforeNavigate(({ to, cancel }) => {
    if ($session.privi > 1) return
    cancel()
    to ? (window.location.href = to.href) : window.location.reload()
  })

  function handle_scroll() {
    if ($navigating) return scroll.reset()
    else scroll.update()
  }
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

{#if $navigating}<Loader />{/if}

<div
  class="app tm-{wtheme} app-fs-{$config.ftsize} app-ff-{$config.ftface}"
  class:kbd-hint={kbd_hint}
  class:_shift={$toleft}>
  <Appbar />

  <main>
    <div class="vessel">
      <Pledge />
      <slot />
    </div>
  </main>

  <footer>
    <div class="foot-notes">
      <a href="/notes/donation" class="foot-link">Ủng hộ trang</a>
    </div>

    <div class="foot-links">
      <strong>Links: </strong>
      {#each links as [text, href]}
        <a {href} class="foot-link" target="_blank" rel="noreferer noopener"
          >{text}</a>
      {/each}
    </div>
  </footer>
</div>

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

  main {
    flex: 1;
    position: relative;
  }

  :global(.vessel) {
    width: $page-width;
    max-width: 100%;
    margin: 0 auto;

    > :global(*) {
      padding: 0 var(--gutter);
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

  .foot-links {
    &:before {
      @include fgcolor(mute);
      margin: 0 0.5rem;
      content: '|';
    }
  }

  // prettier-ignore
  .foot-link {
    font-weight: 500;
    @include fgcolor(primary, 6);
    &:hover { @include fgcolor(primary, 4); }
    & + & { margin-left: 0.5rem; }
  }
</style>
