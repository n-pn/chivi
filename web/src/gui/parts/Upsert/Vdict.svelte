<!-- <script context="module" lang="ts">
  import { make_vdict } from '$utils/vpdict_utils'

  // prettier-ignore
  const basic = [
    '$hanviet', 'fixture', 'essence',
    '$surname', '$pin_yin'
  ]

  // prettier-ignore
  const cvmtl = [
    '~fix_nouns', '~fix_verbs', '~fix_adjts',
    '~qt_times', '~qt_verbs', '~qt_nouns',
    '~v_compl', '~verb_dir', `~v_group`,
    '~v2_objs', '~fix_u_zhi', '~fix_adverbs'
  ]

  const dicts = { basic, cvmtl }

  const groups = {
    basic: 'Cơ bản',
    cvmtl: 'Máy dịch',
  }
</script>

<script lang="ts">
  import Dialog from '$gui/molds/Dialog.svelte'
  import { tooltip } from '$lib/actions'

  export let vdict = make_vdict('$hanviet')
  export let state = 3
  // prettier-ignore
  export let on_close = (_?: any): void => { state = 1 }
</script>

<Dialog actived={state == 3} --z-idx="80" class="vpdict" _size="sm" {on_close}>
  <svelte:fragment slot="header">
    <head-title>Từ điển nâng cao</head-title>
  </svelte:fragment>

  <vpdict-body>
    {#each Object.entries(dicts) as [group, items]}
      <h3><span>{groups[group]}</span></h3>
      <vpdict-list>
        {#each items as dname}
          {@const entry = make_vdict(dname)}
          <button
            class="vpdict-item"
            class:_active={dname == vdict.dname}
            use:tooltip={entry.d_tip}
            data-anchor=".vpdict"
            on:click={() => on_close(entry)}>
            {entry.d_dub}
          </button>
        {/each}
      </vpdict-list>
    {/each}
  </vpdict-body>
</Dialog>

<style lang="scss">
  vpdict-body {
    display: block;
    margin: 0 0.75rem 0.75rem;
  }

  h3 {
    display: flex;
    position: relative;
    margin-top: 0.25rem;
    justify-content: center;
    height: 1.5rem;
    line-height: 1.5rem;

    &:before {
      position: absolute;
      display: block;
      content: '';
      height: 1px;
      top: 50%;
      left: 0;
      right: 0;
      @include border($loc: top);
    }

    > span {
      z-index: 1;
      padding: 0 0.25rem;
      text-transform: uppercase;
      @include ftsize(xs);
      @include fgcolor(tert);
      @include bgcolor(secd);
    }
  }

  vpdict-list {
    @include grid(null, $gap: 0.375rem);
    grid-template-columns: 1fr 1fr 1fr;
    margin-bottom: 0.5rem;
  }

  .vpdict-item {
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
</style> -->
