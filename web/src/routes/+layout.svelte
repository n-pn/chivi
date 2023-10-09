<script lang="ts">
  import '../styles/generic.scss'

  import { onMount, setContext } from 'svelte'
  import { writable } from 'svelte/store'

  import { browser } from '$app/environment'
  import { page, navigating } from '$app/stores'

  import { scroll, toleft, layers, config } from '$lib/stores'
  import { map_keypress, trigger_click } from '$utils/kbd_utils'

  import Loader from '$gui/global/Loader.svelte'
  import Header from '$gui/global/Header.svelte'
  import Pledge from '$gui/global/Pledge.svelte'
  import Footer from '$gui/global/Footer.svelte'
  import { api_get } from '$lib/api_call'

  onMount(() => {
    $config.wtheme = $page.data._conf.wtheme

    let interval = setInterval(short_pulling_user_data, 60000)

    return () => {
      clearInterval(interval)
    }
  })

  const _user = writable($page.data._user)
  setContext('_user', _user)

  const short_pulling_user_data = async () => {
    if ($_user.privi < 0) return

    try {
      $_user = await api_get<App.CurrentUser>('/_db/_self', fetch)
    } catch (ex) {
      console.log(ex)
    }
  }

  $: wtheme = browser ? $config.wtheme : $page.data._conf.wtheme || 'light'

  let kbd_hint = false

  const INPUTS = ['INPUT', 'TEXTAREA', 'TEXT-AREA']
  function handle_keydown(evt: KeyboardEvent) {
    const tag_name = document.activeElement?.tagName
    const on_input = INPUTS.includes(tag_name)

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
</script>

<svelte:window
  on:scroll={handle_scroll}
  on:keydown={handle_keydown}
  on:keyup={() => (kbd_hint = false)} />

<chivi-app class="tm-{wtheme}" class:kbd-hint={kbd_hint} class:_shift={$toleft}>
  {#if $navigating}<Loader />{/if}

  <Header />
  <Pledge />
  <main class="app-vessel"><slot /></main>
  <Footer />
</chivi-app>

<style lang="scss">
  $page-width: 56rem;

  chivi-app {
    --page-width: #{$page-width};

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

  main {
    flex: 1;
    display: flex;
    flex-direction: column;
    position: relative;
  }
</style>
