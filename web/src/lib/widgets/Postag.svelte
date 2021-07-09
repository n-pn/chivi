<script context="module">
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
  import { labels, gnames, groups, find_group } from '$lib/postag'
  import { onMount } from 'svelte'

  export let active = false
  export let postag = ''

  let active_tab = 0
  let origin_tab = 0

  onMount(() => {
    active_tab = find_group(postag)
    origin_tab = find_group(postag)
  })

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

      <section class="tabs">
        {#each gnames as gname, idx}
          <button
            class="-tab"
            class:_active={idx == active_tab}
            class:_origin={idx == origin_tab}
            on:click={() => (active_tab = idx)}>
            {gname}
          </button>
        {/each}
      </section>

      <div class="body">
        {#each groups as tags, idx}
          <section class="tags" class:_active={idx == active_tab}>
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
          </section>
        {/each}
      </div>
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
    background: var(--bg-sub);

    width: 28.5rem;
    max-width: 100vw;

    @include radius();
    @include shadow();
  }

  .head {
    position: relative;
    padding: 0.25rem 0.75rem;
    @include radius($sides: top);

    > * {
      @include fgcolor(neutral, 6);
    }

    > .-tit {
      font-weight: 500;
      line-height: 1.75rem;
      text-align: center;
    }

    > .-btn {
      position: absolute;
      top: 0.25rem;
      right: 0.25rem;
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

  $tab-height: 2rem;

  .tabs {
    display: flex;
    height: $tab-height;
    padding: 0 0.75rem;
    // margin-top: 0.75rem;
    @include border($sides: bottom);
  }

  .-tab {
    // text-transform: capitalize;
    font-weight: 500;
    padding: 0 0.5rem;
    background-color: transparent;

    height: $tab-height;
    line-height: $tab-height;
    flex-shrink: 0;
    margin-right: 0.5rem;

    @include font-size(2);
    @include fgcolor(neutral, 5);
    @include truncate(null);
    @include radius($sides: top);
    @include border($color: neutral, $sides: top-left-right);

    &:hover {
      @include bgcolor(#fff);
    }

    &._origin {
      @include fgcolor(neutral, 7);
    }

    &._active {
      @include bgcolor(#fff);
      @include fgcolor(primary, 6);
      @include bdcolor($color: primary, $shade: 4);
    }
  }

  .body {
    margin-bottom: 0.25rem;
    height: 21rem;
    max-height: calc(100vh - 6.5rem);

    overflow-y: scroll;
    background: #fff;

    // > .-lbl {
    //   @include fgcolor(neutral, 5);
    //   text-transform: uppercase;
    //   font-size: rem(12px);
    //   font-weight: 500;
    //   line-height: 1.5rem;
    //   margin-top: 0.25rem;
    // }
  }

  .tags {
    display: none;
    &._active {
      display: grid;
      width: 100%;
      padding: 0.5rem 0.75rem;
      grid-template-columns: repeat(auto-fill, minmax(6.5rem, 1fr));
      margin-top: 0.25rem;
      grid-gap: 0.5rem;
    }
  }

  .-tag {
    padding: 0 0.5rem;
    background: transparent;
    border-collapse: collapse;
    font-weight: 500;

    height: 1.75rem;
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
</style>
