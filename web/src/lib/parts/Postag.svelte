<script>
  import SIcon from '$atoms/SIcon.svelte'
  import { gnames, groups, find_group, tag_label } from '$lib/postag'
  import { onMount } from 'svelte'

  export let input = ''
  export let state = 1

  let active_tab = 0
  let origin_tab = 0

  $: if (input) {
    origin_tab = find_group(input)
    active_tab = origin_tab > 0 ? origin_tab : 0
  }

  function hide_modal() {
    state = 1
  }

  function update_tag(tag) {
    input = input == tag ? '' : tag
    state = 1
  }
</script>

<div class="wrap" on:click={hide_modal}>
  <div class="main" on:click={(e) => e.stopPropagation()}>
    <header class="head">
      {#each gnames as gname, tab}
        <button
          class="-tab"
          class:_active={tab == active_tab}
          class:_origin={tab == origin_tab}
          on:click={() => (active_tab = tab)}>
          {gname}
        </button>
      {/each}

      <button type="button" class="-btn" on:click={hide_modal}>
        <SIcon name="x" />
      </button>
    </header>

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
  }

  .main {
    width: 32rem;
    max-width: 100vw;

    @include bdradi();
    @include shadow(1);
    @include bgcolor(secd);
  }

  $tab-height: 2rem;

  .head {
    position: relative;
    @include flex($center: horz, $gap: 0.5rem);

    padding: 0.75rem 0.75rem 0;
    height: $tab-height + 0.75rem;

    @include border(--bd-main, $sides: bottom);
    @include bdradi($sides: top);

    > .-btn {
      position: absolute;
      top: 0rem;
      right: 0.25rem;
      background: inherit;
      // width: 1.75rem;
      padding: 0.5rem;
      @include fgcolor(tert);

      &:hover {
        @include fgcolor(primary, 6);
      }
    }

    :global(svg) {
      width: 1.25rem;
      height: 1.25rem;
    }
  }

  .-tab {
    font-weight: 500;
    padding: 0 0.5rem;
    background-color: transparent;

    height: $tab-height;
    line-height: $tab-height;
    flex-shrink: 0;

    @include ftsize(sm);
    @include fgcolor(tert);
    @include clamp($width: null);
    @include bdradi($sides: top);
    @include border(--bd-main, $sides: top-left-right);

    &:hover {
      @include bgcolor(secd);
    }

    &._origin {
      @include fgcolor(secd);
    }

    &._active {
      @include bgcolor(secd);
      @include fgcolor(primary, 5);
      @include bdcolor(primary, 5);
    }
  }

  .body {
    margin-bottom: 0.25rem;
    height: 21rem;
    max-height: calc(100vh - 6.5rem);
    overflow-y: scroll;
    @include bgcolor(secd);
  }

  .tags {
    @include grid(minmax(6.5rem, 1fr), $gap: 0.5rem);
    padding: 0.5rem 0.75rem;

    display: none;
    // prettier-ignore
    &._active { display: grid; }
  }

  .-tag {
    padding: 0 0.5rem;
    background: transparent;
    font-weight: 500;

    height: 1.75rem;
    line-height: 1.75rem;

    @include linesd(--bd-main);

    @include fgcolor(tert);
    @include bdradi(0.75rem);
    @include clamp($width: null);
    @include fluid(font-size, rem(12px), rem(13px), rem(14px));

    &:hover,
    &._active {
      @include fgcolor(primary, 7);
      @include bgcolor(primary, 1);
      @include linesd(primary, 2, $ndef: false);

      @include tm-dark {
        @include fgcolor(primary, 3);
        @include bgcolor(primary, 9);
        @include linesd(primary, 8, $ndef: false);
      }
    }
  }

  .-sep {
    width: 50%;
    grid-column: 1 / -1;
    margin: 0.25rem auto;
    @include border(--bd-main, $sides: top);
  }
</style>
