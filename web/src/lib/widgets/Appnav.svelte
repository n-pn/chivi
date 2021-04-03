<script>
  import { genres, snames, order_names } from '$lib/constants'

  import SIcon from '$lib/blocks/SIcon'
  import Slider from './Slider'

  export let actived = false
</script>

<Slider bind:actived _rwidth={22} _slider="left">
  <svelte:fragment slot="header-left">
    <img src="/chivi-logo.svg" alt="logo" class="-icon" />
    <div class="-text">Chivi</div>
  </svelte:fragment>

  <a href="/" slot="header-right" class="-btn">
    <SIcon name="home" />
  </a>

  <section class="content">
    <header class="label">
      <SIcon name="trending-up" />
      <span>Sắp xếp</span>
    </header>

    <div class="chips">
      {#each Object.entries(order_names) as [name, text]}
        <a href="/?order={name}" class="_chip">
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
        <a href="/?genre={genre}" class="_chip -teal">
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
        <a href="/?sname={sname}" class="_chip -indigo">
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
  .-icon {
    margin: 0.25rem;
  }

  .content {
    margin-top: 0.5rem;
    padding: 0 1rem;
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

    font-size: rem(15px);
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

  .chips {
    @include flow();
    @include props(margin-top, -0.25rem, -0.375rem);
    @include props(margin-left, -0.25rem, -0.375rem);

    @include props(font-size, 11px, 12px);
    @include props(line-height, 1.5rem, 1.75rem);
  }

  ._chip {
    --color: #{color(primary, 6)};
    --hover: #{color(primary, 5)};

    float: left;
    border-radius: 8px;
    padding: 0 0.75em;

    background-color: transparent;
    border: 1px solid var(--hover);

    @include label();
    color: var(--color);
    // letter-spacing: 0.05em;

    @include props(margin-top, 0.25rem, 0.375rem);
    @include props(margin-left, 0.25rem, 0.375rem);

    &.-indigo {
      --color: #{color(indigo, 6)};
      --hover: #{color(indigo, 5)};
    }

    &.-teal {
      --color: #{color(teal, 6)};
      --hover: #{color(teal, 5)};
    }

    &:hover {
      color: #fff;
      background: var(--hover);
    }
  }
</style>
