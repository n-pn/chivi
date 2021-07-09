<script context="module">
  import { labels } from '$lib/postag'

  const data = [
    {
      name: 'Danh từ',
      tags: ['n', 'nr', 'ns', 'nt', 'nw', 'nz', 'ng'],
    },

    {
      name: 'Động từ',
      tags: ['v', 'vn', 'vd', 'vf', 'vx', 'vi', 'vl', 'vg'],
    },

    {
      name: 'Hình dung từ',
      tags: ['a', 'ad', 'an', 'al', 'ag'],
    },
  ]
</script>

<script>
  import SIcon from '$lib/blocks/SIcon.svelte'

  export let active = false
  export let postag = ''

  function hide_modal() {
    active = false
  }

  function trigger_tag(tag) {
    postag = postag == tag ? '' : tag
    active = false
  }
</script>

{#if active}
  <div class="wrap" on:click={hide_modal}>
    <div class="main" on:click={(e) => e.stopPropagation()}>
      <header class="head">
        <div class="-tit">Phân loại từ</div>
        <button type="button" class="-btn" on:click={hide_modal}>
          <SIcon name="x" />
        </button>
      </header>

      <section class="body">
        {#each data as { name, tags }}
          <div class="-lbl">{name}</div>

          <div class="tags">
            {#each tags as tag}
              <button
                class="-tag"
                class:_active={tag == postag}
                on:click={() => trigger_tag(tag)}>
                {labels[tag]}
                {#if tag == postag}
                  <SIcon name="check" />
                {/if}
              </button>
            {/each}
          </div>
        {/each}
      </section>
    </div>
  </div>
{/if}

<style lang="scss">
  .wrap {
    position: fixed;

    top: 0;
    left: 0;
    bottom: 0;
    right: 0;

    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 99999;
    background: rgba(#000, 0.2);
  }

  .main {
    --bg-sub: #{color(neutral, 1)};

    width: 28.5rem;
    max-width: 100vw;
    background: #fff;
    @include radius();
    @include shadow();
  }

  .head {
    display: flex;
    background: var(--bg-sub);
    padding: 0.25rem 0.75rem;
    @include radius($sides: top);

    > * {
      @include fgcolor(neutral, 6);
    }

    > .-tit {
      flex: 1;
      font-weight: 500;
      line-height: 1.75rem;
    }

    > .-btn {
      background: inherit;
      width: 1.75rem;
      margin: 0;
      padding: 0;
    }

    :global(svg) {
      width: rem(20px);
      height: rem(20px);

      &:hover {
        @include fgcolor(primary, 6);
      }
    }
  }

  .body {
    margin: 0.25rem 0 0.75rem;
    padding: 0 0.75rem;

    max-height: 50vh;

    overflow-y: scroll;

    > .-lbl {
      @include fgcolor(neutral, 5);
      text-transform: uppercase;
      font-size: rem(12px);
      font-weight: 500;
      line-height: 1.5rem;
      margin-top: 0.25rem;
    }
  }

  .tags {
    display: grid;
    width: 100%;
    grid-template-columns: repeat(auto-fill, minmax(6.5rem, 1fr));
    margin-top: 0.25rem;
    grid-gap: 0.5rem;

    > .-tag {
      float: left;
      padding: 0 0.5rem;
      background: transparent;
      border-collapse: collapse;
      font-weight: 500;

      line-height: 1.75rem;
      --bdcolor: #{color(neutral, 2)};
      box-shadow: 0 0 0 1px var(--bdcolor);

      @include fgcolor(neutral, 6);
      @include radius(0.75rem);
      @include truncate(null);
      @include props(font-size, rem(12px), rem(13px), rem(14px));

      &:hover,
      &._active {
        @include fgcolor(primary, 7);
        @include bgcolor(primary, 1);
        --bdcolor: #{color(primary, 2)};
      }
    }
  }
</style>
