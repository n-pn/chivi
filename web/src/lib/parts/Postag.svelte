<script>
  import { onMount } from 'svelte'
  import { gnames, groups, find_group, tag_label } from '$lib/pos_tag'

  import SIcon from '$atoms/SIcon.svelte'
  import Gmodal from '$molds/Gmodal.svelte'

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

<Gmodal active={state > 1} index={80} on_close={hide_modal}>
  <postag-wrap>
    <postag-head>
      <postag-tabs>
        {#each gnames as gname, tab}
          <button
            class="postag-tab"
            class:_active={tab == active_tab}
            class:_origin={tab == origin_tab}
            on:click={() => scroll_to_tab(tab)}>
            <span>{gname}</span>
          </button>
        {/each}
      </postag-tabs>

      <button type="button" class="-btn" on:click={hide_modal}>
        <SIcon name="x" />
      </button>
    </postag-head>

    <postag-body>
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
    </postag-body>
  </postag-wrap>
</Gmodal>

<style lang="scss">
  postag-wrap {
    display: block;
    width: 28rem;
    max-width: 100%;
    padding-bottom: 0.25rem;

    @include bdradi();
    @include shadow(1);
    @include bgcolor(secd);

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
  }

  $tab-height: 2rem;

  postag-head {
    @include flex($gap: 0.25rem);
    padding-left: 0.75rem;
    padding-right: 0.25rem;

    height: $tab-height + 0.125rem;
    margin-bottom: 0.25rem;

    @include border(--bd-main, $loc: bottom);
    @include bdradi($loc: top);
    @include bgcolor(tert);

    > .-btn {
      padding: 0.25rem;
      @include fgcolor(tert);
      @include bgcolor(tert);

      &:hover {
        @include fgcolor(primary, 6);
      }
    }

    :global(svg) {
      width: 1.25rem;
      height: 1.25rem;
    }
  }

  postag-tabs {
    flex: 1;
    @include flex-cx($gap: 0.375rem);
  }

  .postag-tab {
    font-weight: 500;
    padding: 0 0.5rem;
    background-color: transparent;

    // height: $tab-height;
    line-height: $tab-height;
    flex-shrink: 0;

    @include ftsize(sm);
    @include fgcolor(tert);
    @include clamp($width: null);
    @include border(--bd-main, $loc: left-right);

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
      @include border(primary, 5, $width: 0.125rem, $loc: top);

      > span {
        display: block;
        margin-top: -0.125rem;
      }
    }
  }

  postag-body {
    display: block;

    height: 22rem;
    max-height: calc(100vh - 6.5rem);
    @include scroll();
    @include bgcolor(secd);
  }

  .tags {
    @include grid(null, $gap: 0.375rem);
    grid-template-columns: 1fr 1fr 1fr;
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
    @include bps(font-size, rem(13px), rem(14px));

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
