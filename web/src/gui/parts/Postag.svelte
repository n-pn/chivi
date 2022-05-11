<script context="module" lang="ts">
  import pt_labels from '$lib/consts/postag_labels.json'
  import pt_briefs from '$lib/consts/postag_briefs.json'

  const gnames = ['Cơ bản', 'Hiếm gặp', 'Đặc biệt']

  const groups = [
    // prettier-ignore
    [
      'nr','ns', 'nt',
      'nn', 'nx', 'nz',
      '-',
      'n', 'nw', 'na',
      't', 's', 'f',
      '-',
      'a', 'ab', 'al',
      'an', 'ad',
      '-',
      'v', 'vn', 'vd',
      'vi', 'vo',
      '-',
    ],
    // prettier-ignore
    [
      'rr', 'rz', 'ry',
      'r',
      '-',
      'vx', 'vm', 'vf',
      '-',
      'm', 'q', 'mq',
      '-',
      'd', 'p', 'u',
      'c', 'cc',
      '-',
      'e', 'y', 'o',
    ],
    // prettier-ignore
    [
      '-',
      'kn', 'ka', 'kv',
      'k',
      '-',
      'x', 'xx', 'xl',
      'w',
      '-',
      '!', '~sv', '~sa',
      '-',
      '~vp', '~ap', 'nl',
      '~pn', '~dp', 'i'
    ],
  ]

  function find_group(tag: string) {
    for (const [idx, group] of groups.entries()) {
      if (group.includes(tag)) return idx
    }

    return -1
  }

  function map_kbd(tag: string) {
    if (tag.length == 1) return tag

    // prettier-ignore
    switch (tag) {
      case 'nr': return '['
      case 'nn': return ']'
      case 'nz': return '.'
      case 'nw': return '/'

      case 'al': return ';'
      case 'vo': return '\''

      default: return ''
    }
  }
</script>

<script lang="ts">
  import { onMount } from 'svelte'
  import { tooltip } from '$lib/actions'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  export let ptag = ''
  export let state = 1

  let active_tab = 0
  let origin_tab = 0

  let modal: HTMLElement | null = null

  onMount(() => {
    if (!ptag) return
    origin_tab = find_group(ptag)
    active_tab = origin_tab > 0 ? origin_tab : 0
    scroll_to_tag(ptag)
  })

  // prettier-ignore
  const on_close = (_?: any) => { state = 1 }

  const pick_tag = (ntag: string) => {
    ptag = ptag == ntag ? '' : ntag
    on_close()
  }

  function scroll_to_tab(tab: number) {
    sections[tab]?.scrollIntoView({ behavior: 'smooth' })
    active_tab = tab
  }

  function scroll_to_tag(tag: string) {
    modal
      ?.querySelector(`.pos-tag[data-tag="${tag}"]`)
      ?.scrollIntoView({ behavior: 'smooth', block: 'center' })
  }

  let sections = []
</script>

<Dialog actived={state == 2} --z-idx={80} class="postag" {on_close}>
  <postag-head slot="header">
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
              data-kbd={map_kbd(ntag)}
              use:tooltip={pt_briefs[ntag]}
              data-anchor=".postag"
              on:click={() => pick_tag(ntag)}>
              <span>{pt_labels[ntag]}</span>
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
</Dialog>

<style lang="scss">
  $tab-height: 1.875rem;

  postag-head {
    @include flex($gap: 0.5rem);
    padding-left: 0.25rem;
    flex: 1;
    height: $tab-height + 0.125rem;
  }

  postag-tabs {
    flex: 1;
    padding-top: 0.375rem;
    @include flex-cx($gap: 0.375rem);
  }

  .postag-tab {
    font-weight: 500;
    padding: 0 0.5rem;
    background-color: transparent;

    height: $tab-height;
    line-height: $tab-height;
    flex-shrink: 0;

    @include ftsize(sm);
    @include fgcolor(tert);

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

  postag-body {
    display: block;
    position: relative;
    padding-top: 0.25rem;
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

    flex-shrink: 1;
    line-height: 1.5rem;

    @include linesd(--bd-main);

    @include fgcolor(tert);
    @include bdradi(0.75rem);
    @include bps(font-size, rem(13px), $pl: rem(14px));
    @include clamp($width: 100%);

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
