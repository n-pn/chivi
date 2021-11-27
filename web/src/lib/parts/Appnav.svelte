<script>
  import { genres, snames, order_names } from '$lib/constants'

  import SIcon from '$atoms/SIcon.svelte'
  import Gslide from '$molds/Gslide.svelte'

  export let actived = false
</script>

<Gslide _klass="appnav" bind:actived _rwidth={22} _slider="left">
  <svelte:fragment slot="header-left">
    <a class="brand" href="/">
      <img src="/icons/chivi.svg" alt="logo" class="-icon" />
      <span>Chivi</span>
    </a>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <a href="/qtran" class="-btn">
      <SIcon name="bolt" />
    </a>

    <a href="/crits" class="-btn">
      <SIcon name="stars" />
    </a>

    <a href="/dicts" class="-btn">
      <SIcon name="package" />
    </a>

    <a href="/" class="-btn">
      <SIcon name="home" />
    </a>
  </svelte:fragment>

  <section class="content">
    <form class="search" action="/search" method="get">
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

    <div class="chips">
      {#each Object.entries(order_names) as [name, text]}
        <a href="/?order={name}" class="-chip">{text}</a>
      {/each}
    </div>
  </section>

  <section class="content">
    <header class="label">
      <SIcon name="folder" />
      <span>Phân loại</span>
    </header>

    <div class="chips">
      {#each genres as genre}
        <a href="/?genre={genre}" class="-chip _green">
          {genre}
        </a>
      {/each}
    </div>
  </section>

  <section class="content">
    <header class="label">
      <SIcon name="archive" />
      <span>Nguồn truyện</span>
    </header>

    <div class="chips">
      {#each snames as sname}
        <a href="/?sname={sname}" class="-chip _orange _caps">
          {sname}
        </a>
      {/each}
    </div>
  </section>
</Gslide>

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

  $-chip-height: 1.75rem;
  .chips {
    // @include flow();
    display: flow-root;
    flex-wrap: nowrap;
    margin-right: -0.375rem;
    margin-bottom: -0.375rem;

    @include bps(font-size, rem(12px), rem(13px), rem(14px));
    line-height: $-chip-height;
  }

  .-chip {
    float: left;
    padding: 0 0.5rem;
    border-radius: math.div($-chip-height, 2);
    // background-color: transparent;

    color: var(--fg-color);
    @include fgvar(color, primary, 6);
    @include linesd(--bd-main);

    font-weight: 500;
    margin-right: 0.375rem;
    margin-bottom: 0.375rem;

    &._green {
      @include fgvar(color, green, 6);
    }

    &._orange {
      @include fgvar(color, orange, 6);
    }

    &._caps {
      font-size: 0.9em;
      text-transform: uppercase;
    }

    &:hover {
      @include linesd(--fg-color, $ndef: false);
    }

    @include tm-dark {
      @include fgvar(color, blue, 4);

      &._green {
        @include fgvar(color, green, 4);
      }

      &._orange {
        @include fgvar(color, orange, 4);
      }
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
