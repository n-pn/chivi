<script context="module">
  import { get_self } from '$api/viuser_api'
  import { u_dname, u_power, l_scroll } from '$src/stores'
  import Loader from '$layout/Loader'

  const links = [
    ['Vozforums', 'https://voz.vn/t/truyen-tau-dich-may-mtl.95881/'],
    ['Facebook', 'https://www.facebook.com/chivi.xyz/'],
    ['Discord', 'https://discord.gg/mdC3KQH'],
  ]
</script>

<script>
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

  function handleScroll() {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop
    $l_scroll = scrollTop - prevScrollTop
    prevScrollTop = scrollTop <= 0 ? 0 : scrollTop
  }
</script>

<svelte:window on:scroll={handleScroll} />

<slot />

<div class="links">
  <span> Liên kết: </span>

  {#each links as [text, href]}
    <a {href} class="-link" target="_blank" rel="noreferer noopener">{text}</a>
  {/each}
</div>

<Loader active={$preloading} />

<style lang="scss">
  :global(#sapper) {
    display: flex;
    flex-direction: column;
    min-height: 100%;
  }

  .links {
    width: 100%;
    text-align: center;
    padding: 0.75rem;

    @include font-size(2);
    @include fgcolor(neutral, 6);
    @include bgcolor(neutral, 2);
    @include border($sides: top);
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
