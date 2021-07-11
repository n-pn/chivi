<script>
  import { genres, snames, order_names } from '$lib/constants'

  import SIcon from '$atoms/SIcon.svelte'
  import Slider from '$molds/Slider.svelte'

  export let actived = false
</script>

<Slider bind:actived _rwidth={22} _slider="left">
  <svelte:fragment slot="header-left">
    <a class="brand" href="/">
      <img src="/chivi-logo.svg" alt="logo" class="-icon" />
      <span>Chivi</span>
    </a>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <a href="/dicts" class="-btn">
      <SIcon name="box" />
    </a>

    <a href="/qtran" class="-btn">
      <SIcon name="zap" />
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
        <a href="/?order={name}" class="-chip">
          {text}
        </a>
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
        <a href="/?genre={genre}" class="-chip _teal">
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
        <a href="/?sname={sname}" class="-chip _indigo _caps">
          {sname}
        </a>
      {/each}
    </div>
  </section>
</Slider>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(neutral, 6);
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
      font-size: rem(18px);
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
    @include fgcolor(neutral, 6);

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

    @include props(font-size, rem(12px), rem(13px), rem(14px));
    line-height: $-chip-height;
  }

  .-chip {
    --color: #{color(primary, 6)};
    --hover: #{color(primary, 5)};
    float: left;
    padding: 0 0.5rem;
    border-radius: math.div($-chip-height, 2);

    background-color: transparent;
    box-shadow: 0 0 0 1px var(--hover) inset;

    // @include label();
    font-weight: 500;
    color: var(--color);
    // letter-spacing: 0.05em;

    margin-right: 0.375rem;
    margin-bottom: 0.375rem;

    &._indigo {
      --color: #{color(indigo, 6)};
      --hover: #{color(indigo, 5)};
    }

    &._teal {
      --color: #{color(teal, 6)};
      --hover: #{color(teal, 5)};
    }

    &._caps {
      font-size: 0.9em;
      text-transform: uppercase;
    }

    &:hover {
      color: #fff;
      background: var(--hover);
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
      outline: none;
      border: none;

      padding: 0.375rem 0.75rem;
      border-radius: 1rem;

      @include bgcolor(neutral, 1);
      box-shadow: 0 0 0 1px color(neutral, 2) inset;

      &:focus {
        box-shadow: 0 0 0 1px color(primary, 4) inset;
      }

      &:hover,
      &:focus {
        background: #fff;
      }

      &::placeholder {
        font-style: italic;
        font-size: rem(15px);
        @include fgcolor(neutral, 6);
      }
    }

    > button {
      position: absolute;
      right: 0.5rem;
      top: 0;
      padding: 0.375rem;
      margin: 0;
      @include fgcolor(neutral, 5);
      background: none;
    }

    :global(svg) {
      width: 1rem;
      height: 1rem;
    }
  }
</style>
