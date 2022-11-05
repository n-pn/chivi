<script lang="ts">
  import '../styles/generic.scss'

  import { browser } from '$app/environment'
  import { page, navigating } from '$app/stores'

  import { scroll, toleft, layers, config } from '$lib/stores'
  import { map_keypress, trigger_click } from '$utils/kbd_utils'

  import Loader from '$gui/global/Loader.svelte'
  import Header from '$gui/global/Header.svelte'
  import Modals from '$gui/global/Modals.svelte'
  import Pledge from '$gui/global/Pledge.svelte'
  import Footer from '$gui/global/Footer.svelte'

  $: wtheme = $page.data.theme || 'white'
  $: if (browser) wtheme = $config.wtheme

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

  // prettier-ignore
  $: meta_desc = $page.data._meta?.desc || 'Công cụ dịch máy từ Tiếng Trung sang Tiếng Việt'
  $: meta_title = $page.data._meta?.title || 'Trang chủ'
</script>

<svelte:window
  on:scroll={handle_scroll}
  on:keydown={handle_keydown}
  on:keyup={() => (kbd_hint = false)} />

<svelte:head>
  <meta name="description" content={meta_desc} />
  <title>{meta_title} - Chivi</title>
</svelte:head>

<chivi-app class="tm-{wtheme}" class:kbd-hint={kbd_hint} class:_shift={$toleft}>
  {#if $navigating}<Loader />{/if}

  <Modals />
  <Header />
  <Pledge />
  <section>
    <main class="app-vessel"><slot /></main>
  </section>
  <Footer />
</chivi-app>

<style lang="scss">
  chivi-app {
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

  :global(.app-vessel) {
    width: $page-width;
    position: relative;
    max-width: 100%;
    margin: 0 auto;
    padding-left: var(--gutter);
    padding-right: var(--gutter);

    > :global(.island) {
      @include bp-max(tl) {
        margin-left: calc(var(--gutter) * -1);
        margin-right: calc(var(--gutter) * -1);
      }
    }
  }

  section {
    flex: 1;
    position: relative;
  }
</style>
