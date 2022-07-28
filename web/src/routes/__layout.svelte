<script context="module" lang="ts">
  import { API } from '$lib/api'

  const links = [
    ['Discord', 'https://discord.gg/mdC3KQH'],
    ['Github', 'https://github.com/np-nam/chivi'],
    ['Facebook', 'https://www.facebook.com/chivi.fb/'],
  ]

  export async function load({ fetch, stuff }) {
    const topbar = {
      right: [
        ['Dịch nhanh', 'bolt', { href: '/qtran', show: 'tm' }],
        ['Đánh giá', 'stars', { href: '/crits', show: 'tm' }],
      ],
      search: '',
    }

    return { stuff: { topbar, api: new API(fetch, stuff) } }
  }
</script>

<script lang="ts">
  import { onMount } from 'svelte'
  import { navigating, session } from '$app/stores'

  import { scroll, toleft, layers, popups, config } from '$lib/stores'
  import { map_keypress, trigger_click } from '$utils/kbd_utils'

  import Pledge from '$gui/sects/layout/Pledge.svelte'
  import Loader from '$gui/sects/layout/Loader.svelte'
  import Topbar from '$gui/sects/layout/Topbar.svelte'

  import Signin from '$gui/parts/Signin.svelte'
  import Appnav from '$gui/parts/Appnav.svelte'
  import Usercp from '$gui/parts/Usercp.svelte'
  import Dboard from '$gui/sects/dboard/Dboard.svelte'

  import '../styles/generic.scss'
  import { browser } from '$app/env'

  onMount(() => {
    if (!$config.wtheme) config.put('wtheme', $session.wtheme || 'light')
  })

  $: wtheme = (browser ? $config.wtheme : $session.wtheme) || 'light'

  let kbd_hint = false

  function handle_keydown(evt: KeyboardEvent) {
    const tag_name = document.activeElement?.tagName
    const on_input = tag_name == 'TEXTAREA' || tag_name == 'INPUT'

    const kbd = map_keypress(evt, on_input)
    if (!kbd) {
      if (evt.shiftKey && (!on_input || evt.altKey)) kbd_hint = true
      return
    }

    const scope = $layers[0]
    const query = evt.key == '"' ? `[data-kbd='${kbd}']` : `[data-kbd="${kbd}"]`
    const query_alt = `[data-key="${evt.code}"]`
    trigger_click(evt, `${scope} ${query}`, `${scope} ${query_alt}`)
  }

  function handle_scroll() {
    if ($navigating) return scroll.reset()
    else scroll.update()
  }

  $: usercp = $session.uname == 'Khách' ? Signin : Usercp
</script>

<svelte:window
  on:scroll={handle_scroll}
  on:keydown={handle_keydown}
  on:keyup={() => (kbd_hint = false)} />

{#if $navigating}<Loader />{/if}

<div class="app tm-{wtheme}" class:kbd-hint={kbd_hint} class:_shift={$toleft}>
  <Topbar />
  <Pledge />

  <Appnav bind:actived={$popups.appnav} />
  <Dboard bind:actived={$popups.dboard} />
  <svelte:component this={usercp} bind:actived={$popups.usercp} />

  <main>
    <div class="vessel">
      <slot />
    </div>
  </main>

  <footer>
    <div class="">
      <a href="/guide/donation" class="foot-link umami--click--check-donation"
        >Ủng hộ trang</a>
    </div>
    <div class="foot-links">
      <strong>Liên kết: </strong>
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

  :global(.vessel) {
    width: $page-width;
    max-width: 100%;
    margin: 0 auto;

    // padding: 0 var(--gutter);
    > :global(*) {
      margin-left: var(--gutter);
      margin-right: var(--gutter);
    }
  }

  main {
    flex: 1;
    position: relative;
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
