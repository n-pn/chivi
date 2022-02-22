<script lang="ts">
  import { snames, order_names, book_origins } from '$lib/constants'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'
  import Bgenre from '$gui/sects/Bgenre.svelte'

  export let actived = false
</script>

<Slider class="appnav" bind:actived _rwidth={22} _slider="left">
  <svelte:fragment slot="header-left">
    <a class="brand" href="/">
      <img src="/icons/chivi.svg" alt="logo" class="-icon" />
      <span>Chivi</span>
    </a>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <a href="/qtran" class="-btn"><SIcon name="bolt" /></a>
    <a href="/crits" class="-btn"><SIcon name="stars" /></a>
    <a href="/dicts" class="-btn"><SIcon name="package" /></a>
    <a href="/" class="-btn"><SIcon name="home" /></a>
  </svelte:fragment>

  <section class="content">
    <form class="search" action="/books/query" method="get">
      <input type="search" name="q" placeholder="Tìm truyện" />
      <button type="submit">
        <SIcon name="search" />
      </button>
    </form>
  </section>

  <section class="content">
    <header class="label">
      <SIcon name="trending-up" />
      <span>Sắp xếp</span>
    </header>

    <div class="m-chips">
      {#each Object.entries(order_names) as [name, text]}
        <a href="/books?order={name}" class="m-chip _primary">{text}</a>
      {/each}
    </div>
  </section>

  <section class="content">
    <header class="label">
      <SIcon name="folder" />
      <span>Phân loại</span>
    </header>

    <Bgenre />
  </section>

  <section class="content">
    <header class="label">
      <SIcon name="archive" />
      <span>Nguồn text</span>
    </header>

    <div class="m-chips">
      {#each snames as sname}
        <a href="/books?sname={sname}" class="m-chip _caps">{sname}</a>
      {/each}
    </div>
  </section>

  <section class="content">
    <header class="label">
      <SIcon name="archive" />
      <span>Trang gốc</span>
    </header>

    <div class="m-chips">
      {#each book_origins as origin}
        <a href="/books?origin={origin}" class="m-chip _caps _private"
          >{origin}</a>
      {/each}
    </div>
  </section>
</Slider>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(secd);
  }

  .brand {
    display: flex;
    flex: 1;
    // padding: 0.25rem 0;
    > img {
      margin-top: 0.375rem;
      margin-right: 0.5rem;
      display: block;
      width: 1.5rem;
      height: 1.5rem;
    }

    > span {
      @include label();
      @include ftsize(lg);
      line-height: 2.375rem;
      letter-spacing: 0.04rem;
    }
  }

  .-icon {
    margin: 0.25rem;
  }

  .content {
    margin-top: 0.5rem;
    padding: 0 0.75rem;
  }

  .label {
    @include flex();
    // @include label();
    font-weight: 500;
    line-height: 2.25rem;
    margin: 0 -0.5rem;
    margin-bottom: 0.25rem;
    padding: 0 0.5rem;
    // text-transform: uppercase;

    // font-size: rem(15px);
    @include fgcolor(tert);

    :global(svg) {
      margin-top: 0.5rem;
      width: 1.25rem;
      height: 1.25rem;
    }

    span {
      margin-left: 0.5rem;
    }
  }

  .search {
    display: block;
    width: 100%;
    position: relative;
    margin-top: 1rem;

    > input {
      display: block;
      width: 100%;
      padding: 0.375rem 0.75rem;

      border: none;
      outline: none;
      border-radius: 1rem;

      @include fgcolor(main);
      @include bgcolor(main);
      @include linesd(--bd-main);

      &:focus {
        @include linesd(primary, 5, $width: 2px, $ndef: false);
      }

      &:hover,
      &:focus {
        @include bgcolor(bg-secd);
      }

      &::placeholder {
        font-style: italic;
        font-size: rem(15px);
        color: var(--fg-tert);
      }
    }

    > button {
      position: absolute;
      right: 0.5rem;
      top: 0;
      padding: 0.375rem;
      margin: 0;
      background: none;
      @include fgcolor(neutral, 5);
    }

    :global(svg) {
      width: 1rem;
      height: 1rem;
    }
  }
</style>
