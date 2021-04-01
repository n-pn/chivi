<script>
  import { genres, snames, order_names } from '$lib/constants'

  import SIcon from '$lib/blocks/SIcon'
  import Slider from './Slider'

  export let actived = false

  function jumpto(node, url) {
    const action = () => {
      _goto_(url)
      actived = false
    }

    node.addEventListener('click', action)
    return { destroy: () => node.removeEventListener('click', action) }
  }
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
      {#each snames as _sname}
        <button use:jumpto={`/?sname=${_sname}`} class="-chip _indigo">
          {_sname}
        </button>
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
    text-transform: uppercase;
    @include font-size(2);
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

  .-chip {
    float: left;
    border-radius: 0.75rem;
    padding: 0 0.75em;
    @include label();

    background-color: #fff;
    @include fgcolor(primary, 6);
    @include border($color: primary, $shade: 5);

    @include props(margin-top, 0.25rem, 0.375rem);
    @include props(margin-left, 0.25rem, 0.375rem);

    &:hover {
      @include bgcolor($color: primary, $shade: 5);
      color: #fff;
    }

    &._indigo {
      @include fgcolor(indigo, 6);
      @include bdcolor($color: indigo, $shade: 5);
      &:hover {
        @include bgcolor($color: indigo, $shade: 5);
        color: #fff;
      }
    }

    &._teal {
      @include fgcolor(teal, 6);
      @include bdcolor($color: teal, $shade: 5);
      &:hover {
        @include bgcolor($color: teal, $shade: 5);
        color: #fff;
      }
    }
  }
</style>
