<script context="module" lang="ts">
  import pt_labels from '$lib/consts/postag_labels.json'
  import pt_briefs from '$lib/consts/postag_briefs.json'

  // prettier-ignore
  const names = [
    'Nr', 'Na', 'Nl',
    'Nw', 'Nz'
  ]

  // prettier-ignore
  const nouns = [
    'nv', 'no', 'nc',
    'nt', 'ns', 'nf',
    'nh', 'na', 'n'
  ]

  // prettier-ignore
  const adjts = [
    'a', 'ab', 'az',
    'an', 'ad', 'av',
    'al', '~na'
  ]

  // prettier-ignore
  const verbs = [
    'v', 'vi', 'vo',
    'vn', 'vd', 'vj',
    'vc', 'vm', 'vf'
  ]

  // prettier-ignore
  const pronouns = [
    'rr', 'rz', 'ry',
    'r'
  ]

  // prettier-ignore
  const numbers = [
    'm', 'q', 'mq',
    'qx', 'mqx'
  ]

  // prettier-ignore
  const extras = [
    'k', 'kx', 'kl',
    '!', 'i', ''
  ]

  // prettier-ignore
  const adverbs = [
    'd', 'ad', 'vd'
  ]

  // prettier-ignore
  const functions = [
    'c', 'p', 'u',
    'xe', 'xo', 'xy'
  ]

  // prettier-ignore
  const literals = [
    'x', 'xx', 'xl',
    'xq', 'xt', 'w'
  ]

  // prettier-ignore
  const phrases = [
    '~nl', '~al', '~vl',
    '~dv', '~da', '~dp',
    '~pn', '~na', '~sv',
  ]

  // const labels = ['Cơ bản', 'Hiếm gặp', 'Đặc biệt']

  const tabs = [
    {
      name: 'Danh từ riêng/chung',
      ptags: [names, nouns],
    },
    {
      name: 'Tính từ / Động từ',
      ptags: [adjts, verbs],
    },
    {
      name: 'Số từ / Đại từ / Thực từ khác',
      ptags: [numbers, pronouns, extras],
    },
    {
      name: 'Phó từ / Liên từ / Trợ từ / Giới từ',
      ptags: [adverbs, functions],
    },
    {
      name: 'Từ ngoại lai / Dấu câu / Cấu trúc',
      ptags: [literals, phrases],
    },
  ]

  function in_group(groups: string[][], ptag: string): boolean {
    for (const group of groups) {
      if (group.includes(ptag)) return true
    }
    return false
  }

  function map_kbd(tag: string) {
    if (tag.length == 1) return tag

    // prettier-ignore
    switch (tag) {
      case 'Nr': return '['
      case 'Na': return ']'
      case 'Nz': return '.'
      case 'Nw': return '/'
      case 'al': return ';'
      case 'vo': return '\''
      default: return ''
    }
  }
</script>

<script lang="ts">
  import { tooltip } from '$lib/actions'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  export let ptag = ''
  export let state = 1

  // prettier-ignore
  const on_close = (_?: any) => { state = 1 }

  const pick_tag = (ntag: string) => {
    ptag = ntag
    on_close()
  }

  let open_tab = 0

  $: map_open_tab(ptag)

  function map_open_tab(ptag: string) {
    for (let i = 0; i < tabs.length; i++) {
      if (in_group(tabs[i].ptags, ptag)) {
        open_tab = i
        return
      }
    }
    open_tab = 0
  }
</script>

<Dialog actived={state == 2} --z-idx={80} class="postag" {on_close}>
  <postag-head slot="header">
    <postag-tabs>
      {#each tabs as { label }, tab}
        <button
          class="postag-tab"
          class:_active={tab == open_tab}
          data-tip={label}
          data-kbd={tab + 1}
          on:click={() => (open_tab = tab)}>
          <span>Nhóm {tab + 1}</span>
        </button>
      {/each}
    </postag-tabs>
  </postag-head>

  <postag-body>
    {#each tabs as { label, ptags }, index}
      {@const open = index == open_tab}
      <details id="ptg-{index}" {open}>
        <summary class:active={open}>{label}</summary>
        {#each ptags as tags, pi}
          {#if pi > 0}<section class="sep" />{/if}

          <section class="tags">
            {#each tags as itag}
              {@const active = itag == ptag}
              <button
                class="pos-tag"
                class:_active={active}
                data-tag={itag}
                data-kbd={map_kbd(itag)}
                use:tooltip={pt_briefs[itag]}
                data-anchor=".postag"
                on:click={() => pick_tag(itag)}>
                <span>{pt_labels[itag]}</span>
                {#if active}<SIcon name="check" />{/if}
              </button>
            {/each}
          </section>
        {/each}
      </details>
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
    @include flex-cx($gap: 0.25rem);
  }

  .postag-tab {
    font-weight: 500;
    padding: 0 0.375rem;
    background-color: transparent;

    height: $tab-height;
    line-height: $tab-height;
    flex-shrink: 0;

    @include ftsize(xs);
    @include fgcolor(tert);

    @include bdradi($loc: top);
    @include border(--bd-main, $loc: top-left-right);

    &:hover {
      @include bgcolor(secd);
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
    // padding-top: 0.25rem;
    padding-bottom: 0.75rem;
    height: 22rem;
    max-height: calc(100vh - 6.5rem);
    @include scroll();
    @include bgcolor(secd);
  }

  summary {
    font-weight: 500;
    line-height: 2.25rem;
    margin: 0rem 0.75rem;
    font-size: rem(15px);
    @include fgcolor(tert);

    &.active {
      @include fgcolor(primary);
    }
  }

  .tags {
    @include grid(null, $gap: 0.375rem);
    grid-template-columns: 1fr 1fr 1fr;
    padding: 0 0.75rem;
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

  .sep {
    display: block;
    margin: 0.375rem 0;

    &::after {
      display: block;
      content: '';
      width: 66%;
      margin: 0 auto;
      @include border(--bd-main, $loc: top);
    }
  }

  // .-sep {
  //   width: 50%;
  //   grid-column: 1 / -1;
  //   margin: 0.125rem auto;
  //   @include border(--bd-main, $loc: top);
  // }
</style>
