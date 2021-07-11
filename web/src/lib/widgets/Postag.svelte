<script>
  import SIcon from '$lib/blocks/SIcon.svelte'
  import { gnames, groups, find_group, tag_label } from '$lib/postag'
  import { onMount } from 'svelte'

  export let input = ''
  export let state = 1

  let active_tab = 0
  let origin_tab = 0

  onMount(() => {
    origin_tab = find_group(input)
    active_tab = origin_tab > 0 ? origin_tab : 0
  })

  function hide_modal() {
    state = 1
  }

  function update_tag(tag) {
    input = input == tag ? '' : tag
    state = 1
  }
</script>

<div class="wrap" class:_active={state > 1} on:click={hide_modal}>
  <div class="main" on:click={(e) => e.stopPropagation()}>
    <header class="head">
      <div class="-tit">Phân loại từ</div>
      <button type="button" class="-btn" on:click={hide_modal}>
        <SIcon name="x" />
      </button>
    </header>

    <section class="tabs">
      {#each gnames as gname, tab}
        <button
          class="-tab"
          class:_active={tab == active_tab}
          class:_origin={tab == origin_tab}
          on:click={() => (active_tab = tab)}>
          {gname}
        </button>
      {/each}
    </section>

    <div class="body">
      {#each groups as tags, tab}
        <section class="tags" class:_active={tab == active_tab}>
          {#each tags as tag}
            {#if tag != '-'}
              <button
                class="-tag"
                class:_active={tag == input}
                on:click={() => update_tag(tag)}>
                {tag_label(tag)}
                {#if tag == input}
                  <SIcon name="check" />
                {/if}
              </button>
            {:else}
              <div class="-sep" />
            {/if}
          {/each}
        </section>
      {/each}
    </div>
  </div>
</div>

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
    z-index: 10000;

    background: rgba(#000, 0.2);
    visibility: hidden;

    &._active {
      visibility: visible;
    }
  }

  .main {
    --bg-sub: #{color(neutral, 1)};
    background: var(--bg-sub);

    width: 32rem;
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
    max-height: calc(100vh - 4.5rem);

    overflow-y: scroll;
    background: #fff;
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

  .-sep {
    width: 50%;

    grid-column: 1 / -1;
    border-top: 1px solid color(neutral, 3);
    margin: 0.25rem auto;
  }
</style>
