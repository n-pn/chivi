<script context="module">
  import { get_self } from '$api/viuser_api'

  import { u_dname, u_power, l_scroll } from '$src/stores'

  import { onMount } from 'svelte'

  let prevScrollTop = 0

  function handle_scroll() {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop
    l_scroll.set(scrollTop - prevScrollTop)
    prevScrollTop = scrollTop <= 0 ? 0 : scrollTop
  }
</script>

<script>
  import Loader from '$layout/Loader'

  import { stores } from '@sapper/app'
  const { preloading } = stores()

  onMount(async () => {
    const [err, user] = await get_self(fetch)
    if (err) {
      $u_dname = 'Khách'
      $u_power = 0
    } else {
      $u_dname = user.dname
      $u_power = user.power
    }
  })

  const links = [
    ['Vozforums', 'https://voz.vn/t/truyen-tau-dich-may-mtl.95881/'],
    ['Facebook', 'https://www.facebook.com/chivi.xyz/'],
    ['Discord', 'https://discord.gg/mdC3KQH'],
  ]
</script>

<svelte:window on:scroll={handle_scroll} />

<slot />

<footer class="guide">
  <span> Liên kết hỗ trợ: </span>
  {#each links as [text, href]}
    <a {href} class="link" target="_blank" rel="noreferer noopener">{text}</a>
  {/each}
</footer>

<Loader active={$preloading} />

<style lang="scss">
  :global(#sapper) {
    display: flex;
    flex-direction: column;
    min-height: 100%;
  }

  .guide {
    width: 100%;
    text-align: center;
    padding: 0.75rem;
    @include font-size(2);
    @include fgcolor(neutral, 6);
    @include bgcolor(neutral, 2);
    @include border($sides: top);
  }

  .link {
    margin-left: 0.375rem;
    font-weight: 500;
    @include fgcolor(primary, 6);
    &:hover {
      @include fgcolor(primary, 4);
    }
  }
</style>
