<script>
  import { get_self } from '$api/viuser_api'
  import { u_dname, u_power, l_scroll, dark_mode } from '$src/stores'
  import Loader from '$lib/layouts/Loader.svelte'

  import '../css/globals.scss'

  const links = [
    ['Vozforums', 'https://voz.vn/t/truyen-tau-dich-may-mtl.95881/'],
    ['Facebook', 'https://www.facebook.com/chivi.xyz/'],
    ['Telegram', 'https://t.me/chivi_xyz'],
    ['Discord', 'https://discord.gg/mdC3KQH'],
    ['Github', 'https://github.com/np-nam/chivi'],
  ]

  import { onMount } from 'svelte'

  import { stores } from '@sapper/app'
  const { preloading, page } = stores()

  onMount(async () => {
    // TODO: load user from session
    const [err, user] = await get_self(fetch)

    if (err) {
      $u_dname = 'Khách'
      $u_power = 0
    } else {
      $u_dname = user.dname
      $u_power = user.power
    }
  })

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
  //   if ($u_power < 2) e.stopPropagation()
  // }

  let root
  onMount(() => (root = document.documentElement))
  $: root && root.classList.toggle('tm-dark', $dark_mode)
</script>

<svelte:window on:scroll={track_scrolling} />

<div class="app">
  <slot />

  <div class="links">
    <span> Liên kết: </span>

    {#each links as [text, href]}
      <a {href} class="-link" target="_blank" rel="noreferer noopener"
        >{text}</a>
    {/each}
  </div>
</div>

<Loader active={$preloading} />

<style lang="scss">
  :global(#sapper) {
    display: flex;
    flex-direction: column;
    min-height: 100%;
  }

  .app {
    height: 100%;

    @include tm-dark {
      background: color(neutral, 8);
    }
  }

  .links {
    width: 100%;
    text-align: center;
    padding: 0.75rem;

    @include font-size(2);
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
