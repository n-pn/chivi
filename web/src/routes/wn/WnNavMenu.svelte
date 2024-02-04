<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let tab = ''

  const tabs = [
    ['/wn', 'Thư viện', 'books'],
    ['/uc/crits', 'Đánh giá', 'stars'],
    ['/uc/lists', 'Thư đơn', 'bookmarks'],
  ]
</script>

<nav class="nav-menu">
  {#each tabs as [href, text, icon]}
    <a class="nav-link" class:_active={href == tab} {href}>
      <SIcon name={icon} />
      <span class="nav-text">{text}</span>
    </a>
  {/each}
</nav>

<style lang="scss">
  .nav-menu {
    @include flex-ca;
    gap: 0.5rem;
    margin: 0.75rem 0;
  }

  .nav-link {
    @include flex-cy($gap: 0.25rem);

    @include bps(font-size, rem(13px), $pl: rem(14px));
    @include bps(line-height, 1.75rem, $pl: 2rem);

    padding: 0 0.75em;
    font-weight: 500;
    text-transform: uppercase;

    // border-radius: 1rem;
    @include bdradi;

    @include clamp($width: null);
    @include fgcolor(tert);

    @include linesd(--bd-main);

    &._active,
    &:hover {
      @include fgcolor(primary, 6);
      @include linesd(primary, 5, $ndef: false);
    }

    @include tm-dark {
      &._active,
      &:hover {
        @include fgcolor(primary, 4);
      }
    }
  }
</style>
