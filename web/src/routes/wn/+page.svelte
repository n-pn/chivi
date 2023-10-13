<script context="module" lang="ts">
  const order_names = {
    bumped: 'Vừa xem',
    update: 'Đổi mới',
    rating: 'Đánh giá',
    weight: 'Tổng hợp',
  }
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import Footer from '$gui/sects/Footer.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import WninfoList from '$gui/parts/wninfo/WninfoList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ books, pgidx, pgmax } = data)
  $: pager = new Pager($page.url, { order: 'bumped', pg: 1 })
</script>

<div class="order">
  {#each Object.entries(order_names) as [type, label]}
    <a
      href={pager.gen_url({ pg: 1, order: type })}
      class="-type"
      class:_active={pager.get('order') == type}>
      <span>{label}</span>
    </a>
  {/each}
</div>

{#if books.length > 0}
  <WninfoList {books} />
{:else}
  <div class="d-empty">Danh sách trống</div>
{/if}

<Footer>
  <Mpager {pager} {pgidx} {pgmax} />
</Footer>

<style lang="scss">
  :global(#svelte) {
    height: 100%;
  }

  .order {
    @include flex($center: horz, $gap: 0.5rem);

    margin: 1rem 0;

    @include bps(font-size, rem(13px), $pl: rem(14px));
    @include bps(line-height, 1.75rem, $pl: 2rem);

    .-type {
      padding: 0 0.75em;
      font-weight: 500;
      text-transform: uppercase;
      @include clamp($width: null);
      @include fgcolor(tert);

      @include linesd(--bd-main);
      @include bdradi();

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
  }
</style>
