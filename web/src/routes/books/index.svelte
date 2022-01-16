<script context="module">
  import { page } from '$app/stores'
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ url, fetch }) {
    const api_url = new URL(url)
    api_url.pathname = '/api/books'
    api_url.searchParams.set('take', 24)

    const api_res = await fetch(api_url.toString())
    if (!api_res.ok) {
      return { status: api_res.status, error: await api_res.text() }
    }

    appbar.set({
      query: '',
      right: [
        [
          'Thêm truyện',
          'file-plus',
          'link',
          { href: '/books/+new', _text: '_show-lg' },
        ],
      ],
    })
    return { props: await api_res.json() }
  }

  const order_names = {
    bumped: 'Vừa xem',
    update: 'Đổi mới',
    rating: 'Đánh giá',
    weight: 'Tổng hợp',
  }
</script>

<script>
  import Nvlist from '$parts/Nvlist.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'

  export let books = []
  export let pgidx = 1
  export let pgmax = 1

  $: pager = new Pager($page.url, { order: 'bumped', page: 1 })
</script>

<svelte:head>
  <title>Chivi - Truyện tàu dịch máy</title>
</svelte:head>

<Vessel>
  <div class="order">
    {#each Object.entries(order_names) as [type, label]}
      <a
        href={pager.make_url({ page: 1, order: type })}
        class="-type"
        class:_active={pager.get('order') == type}>
        <span>{label}</span>
      </a>
    {/each}
  </div>

  {#if books.length > 0}
    <Nvlist {books} />
  {:else}
    <div class="empty">Danh sách trống</div>
  {/if}

  <svelte:fragment slot="footer">
    <Mpager {pager} {pgidx} {pgmax} />
  </svelte:fragment>
</Vessel>

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

  .empty {
    display: flex;
    min-height: 50vh;
    align-items: center;
    justify-content: center;
    font-style: italic;
    @include fgcolor(neutral, 6);
  }
</style>
