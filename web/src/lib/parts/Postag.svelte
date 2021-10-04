<script>
  import { onMount } from 'svelte'
  import { scale, fade } from 'svelte/transition'
  import { backInOut } from 'svelte/easing'
  import SIcon from '$atoms/SIcon.svelte'
  import { gnames, groups, find_group, tag_label } from '$lib/pos_tag'

  export let ptag = ''
  export let state = 1

  let active_tab = 0
  let origin_tab = 0

  let modal

  onMount(() => {
    if (!ptag) return

    origin_tab = find_group(ptag)
    active_tab = origin_tab > 0 ? origin_tab : 0
    // scroll_to_tab(active_tab)
    scroll_to_tag(ptag)
  })

  function hide_modal() {
    state = 1
  }

  function update_tag(ntag) {
    ptag = ptag == ntag ? '' : ntag
    state = 1
  }

  function scroll_to_tab(tab) {
    sections[tab]?.scrollIntoView({ behavior: 'smooth' })
    active_tab = tab
  }

  function scroll_to_tag(tag) {
    modal
      ?.querySelector(`.pos-tag[data-tag="${tag}"]`)
      ?.scrollIntoView({ behavior: 'smooth', block: 'center' })
  }

  let sections = []
</script>

<modal-wrap transition:fade={{ duration: 100 }} on:click={hide_modal}>
  <modal-main
    on:click={(e) => e.stopPropagation()}
    transition:scale={{ duration: 100, easing: backInOut }}
    bind:this={modal}>
    <modal-head>
      {#each gnames as gname, tab}
        <button
          class="-tab"
          class:_active={tab == active_tab}
          class:_origin={tab == origin_tab}
          on:click={() => scroll_to_tab(tab)}>
          {gname}
        </button>
      {/each}

      <button type="button" class="-btn" on:click={hide_modal}>
        <SIcon name="x" />
      </button>
    </modal-head>

    <modal-body>
      {#each groups as tags, tab}
        <section class="tags" bind:this={sections[tab]}>
          {#each tags as ntag}
            {#if ntag != '-'}
              <button
                class="pos-tag"
                class:_active={ntag == ptag}
                data-tag={ntag}
                on:click={() => update_tag(ntag)}>
                <span>{tag_label(ntag)}</span>
                {#if ntag == ptag}
                  <SIcon name="check" />
                {/if}
              </button>
            {:else}
              <div class="-sep" />
            {/if}
          {/each}
        </section>
      {/each}
    </modal-body>
  </modal-main>
</modal-wrap>

<style lang="scss">
  modal-wrap {
    position: fixed;

    top: 0;
    left: 0;
    bottom: 0;
    right: 0;

    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;

    background: rgba(#000, 0.4);
  }

  modal-main {
    display: block;
    width: 28rem;
    max-width: 100vw;

    @include bdradi();
    @include shadow(1);
    @include bgcolor(secd);

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
  }

  $tab-height: 2rem;

  modal-head {
    position: relative;
    @include flex($center: horz, $gap: 0.5rem);

    padding: 0.75rem 0.75rem 0;
    height: $tab-height + 0.75rem;

    @include border(--bd-main, $loc: bottom);
    @include bdradi($loc: top);

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
    @include bdradi($loc: top);
    @include border(--bd-main, $loc: top-left-right);

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

  modal-body {
    display: block;
    margin-bottom: 0.25rem;
    height: 21rem;
    max-height: calc(100vh - 6.5rem);
    @include scroll();
    @include bgcolor(secd);
  }

  .tags {
    @include grid(minmax(6.5rem, 1fr), $gap: 0.375rem);
    padding: 0.5rem 0.75rem;
  }

  .pos-tag {
    padding: 0.25rem 0.5rem;
    background: transparent;
    font-weight: 500;

    line-height: 1.5rem;

    @include linesd(--bd-main);

    @include fgcolor(tert);
    @include bdradi(0.75rem);
    @include clamp($width: null);
    @include bps(font-size, rem(12px), rem(13px), rem(14px));

    &:hover,
    &._active {
      @include fgcolor(primary, 7);
      @include bgcolor(primary, 1);
      @include linesd(primary, 2, $ndef: false);

      @include tm-dark {
        @include fgcolor(primary, 3);
        @include bgcolor(primary, 9, 5);
        @include linesd(primary, 8, $ndef: false);
      }
    }
  }

  .-sep {
    width: 50%;
    grid-column: 1 / -1;
    margin: 0.125rem auto;
    @include border(--bd-main, $loc: top);
  }
</style>
