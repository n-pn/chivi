<script lang="ts">
  import { page } from '$app/stores'
  import Footer from '$gui/sects/Footer.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import UpstemCard from '$gui/parts/upstem/UpstemCard.svelte'

  import type { PageData } from './$types'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { goto } from '$app/navigation'
  export let data: PageData

  $: ({ items, pgidx, pgmax } = data.props)
  $: pager = new Pager($page.url, { pg: 1 })

  const remove_query = (key: string) => {
    delete data.query[key]
    invoke_query()
  }
  const invoke_query = () => {
    const input = Object.entries(data.query)
    let query = input.map(([k, v]) => (v ? `${k}=${v}` : ''))
    query = query.filter(Boolean)
    goto(query.length > 0 ? `/up?${query.join('&')}` : '/up')
  }

  const placeholders = {
    by: 'Người dùng',
    wn: 'Truyện chữ',
    lb: 'Nhãn dự án',
  }

  const filter_icons = {
    by: 'user',
    wn: 'book',
    lb: 'tags',
  }
</script>

<header>
  <form
    class="search"
    action="/rm"
    method="GET"
    on:submit|preventDefault={invoke_query}>
    {#each ['by', 'lb', 'wn'] as key}
      {@const placeholder = placeholders[key]}
      {@const filter_icon = filter_icons[key]}
      <div class="sinput">
        <SIcon name={filter_icon} class="fsicon" />
        <input
          class="m-input _sm"
          type="search"
          {placeholder}
          bind:value={data.query[key]} />
        {#if data.query[key]}
          <button type="button" on:click={() => remove_query(key)}>
            <SIcon name="x" />
          </button>
        {/if}
      </div>
    {/each}
    <button class="m-btn _primary _fill _sm" type="submit">
      <SIcon name="search" />
    </button>
  </form>
</header>

<section class="section">
  {#each items as ustem}
    <UpstemCard {ustem} />
  {:else}
    <div class="empty">Danh sách trống</div>
  {/each}
</section>

<Footer>
  <Mpager {pager} {pgidx} {pgmax} />
</Footer>

<style lang="scss">
  .section {
    margin-top: 1rem;
    @include bp-min(tl) {
      padding-left: var(--gutter);
      padding-right: var(--gutter);
    }
  }

  // .order {
  //   @include flex($center: horz, $gap: 0.5rem);

  //   margin: 1rem 0;

  //   @include bps(font-size, rem(13px), $pl: rem(14px));
  //   @include bps(line-height, 1.75rem, $pl: 2rem);

  //   .-type {
  //     padding: 0 0.75em;
  //     font-weight: 500;
  //     text-transform: uppercase;
  //     @include clamp($width: null);
  //     @include fgcolor(tert);

  //     @include linesd(--bd-main);
  //     @include bdradi();

  //     &._active,
  //     &:hover {
  //       @include fgcolor(primary, 6);
  //       @include linesd(primary, 5, $ndef: false);
  //     }

  //     @include tm-dark {
  //       &._active,
  //       &:hover {
  //         @include fgcolor(primary, 4);
  //       }
  //     }
  //   }
  // }

  .empty {
    display: flex;
    min-height: 50vh;
    align-items: center;
    justify-content: center;
    font-style: italic;
    @include fgcolor(neutral, 6);
  }

  .search {
    @include flex-ca;
    gap: 0.5rem;
    margin: 1rem 0;
  }

  .sinput {
    position: relative;
    flex: 1;
    @include flex-ca;

    button {
      @include flex-ca;
      background-color: inherit;
      @include fgcolor(tert);
      position: absolute;
      right: 0.25rem;

      &:hover {
        @include fgcolor(primary);
      }
    }

    input {
      padding-left: 2rem;
      padding-right: 1rem;
      width: 100%;

      @include ftsize(sm);
      @include fgcolor(secd);
      display: inline-block;
    }

    :global(.fsicon) {
      @include fgcolor(mute);
      position: absolute;
      left: 0.75rem;
    }
  }
</style>
