<script context="module">
  const dicts = ['hanviet', 'fixture', 'essence']
  import { make_vdict } from '$utils/vpdict_utils'
</script>

<script>
  import Dialog from '$molds/Dialog.svelte'
  import { tooltip } from '$utils/custom_actions'

  export let vdict = make_vdict('hanviet')
  export let state = 3
  export let on_close = () => (state = 1)
</script>

<Dialog actived={state == 3} --z-idx="80" class="vpdict" _size="sm" {on_close}>
  <svelte:fragment slot="header">
    <head-title>Chọn từ điển</head-title>
  </svelte:fragment>

  <vpdict-body>
    {#each dicts as dname}
      {@const entry = make_vdict(dname)}
      <button
        class="vpdict-item"
        class:_active={dname == vdict.dname}
        use:tooltip={entry.descs}
        on:click={() => on_close(entry)}>
        {entry.d_dub}
      </button>
    {/each}
  </vpdict-body>
</Dialog>

<style lang="scss">
  vpdict-body {
    @include grid(null, $gap: 0.375rem);
    grid-template-columns: 1fr 1fr 1fr;
    padding: 0.5rem 0.75rem;
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
</style>
