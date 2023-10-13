<script lang="ts">
  import { page } from '$app/stores'
  import { status_types, status_names } from '$lib/constants'

  import WninfoList from '$gui/parts/wninfo/WninfoList.svelte'
  import Footer from '$gui/sects/Footer.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ books, pgidx, pgmax, bmark } = data)

  $: pager = new Pager($page.url)
</script>

<div class="tabs">
  {#each status_types as status}
    <a href="/me/books/{status}" class="tab" class:_active={status == bmark}>
      {status_names[status]}
    </a>
  {/each}
</div>

<WninfoList {books} nvtab="chaps" />

<Footer>
  <div class="pagi">
    <Mpager {pager} {pgidx} {pgmax} />
  </div>
</Footer>

<style lang="scss">
  .tabs {
    @include flex($center: horz, $gap: 0.5rem);
    margin: 1rem 0;
  }

  .tab {
    font-weight: 500;
    text-transform: uppercase;

    padding: 0 0.75rem;
    @include bps(font-size, rem(13px), $tm: rem(14px));
    @include bps(line-height, 1.75rem, $tm: 2rem);

    @include bdradi();
    @include clamp($width: null);
    @include linesd(--bd-main);
    @include fgcolor(tert);

    &:hover,
    &._active {
      @include fgcolor(primary, 6);
    }

    &._active {
      @include linesd(primary, 5, $ndef: false);
      // overflow: auto;
    }

    @include tm-dark {
      &._active,
      &:hover {
        @include fgcolor(primary, 4);
      }
    }
  }

  .pagi {
    @include flex($center: horz, $gap: 0.375rem);
  }
</style>
