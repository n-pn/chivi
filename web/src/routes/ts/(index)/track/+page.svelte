<script lang="ts">
  import { rstate_labels } from '$lib/consts/rd_states'
  import TsrepoList from '$gui/shared/tsrepo/TsrepoList.svelte'

  import type { PageData } from './$types'
  export let data: PageData
  $: ({ repos, memos, pgidx, pgmax } = data.table)
</script>

<div class="tabs">
  {#each rstate_labels as label, value}
    <a href="/ts/track?state={value}" class="tab" class:_active={value == data.state}>
      <span>{value > 0 ? label : 'Tất cả'}</span>
    </a>
  {/each}
</div>

<TsrepoList {repos} {memos} {pgidx} {pgmax} />

<style lang="scss">
  .tabs {
    @include flex($center: horz, $gap: 0.5rem);
    margin: 1rem 0;
  }

  .tab {
    font-weight: 500;
    text-transform: uppercase;

    padding: 0 0.75rem;
    @include bps(font-size, rem(13px), $tm: rem(14px));
    @include bps(line-height, 1.75rem, $tm: 2rem);

    @include bdradi();
    @include clamp($width: null);
    @include linesd(--bd-main);
    @include fgcolor(tert);

    &:hover,
    &._active {
      @include fgcolor(primary, 6);
    }

    &._active {
      @include linesd(primary, 5, $ndef: false);
      // overflow: auto;
    }

    @include tm-dark {
      &._active,
      &:hover {
        @include fgcolor(primary, 4);
      }
    }
  }
</style>
