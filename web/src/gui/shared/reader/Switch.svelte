<script lang="ts">
  import type { Pager } from '$lib/pager'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let pager: Pager
  export let xargs: CV.Chopts
  export let modes: Record<string, string> = {}
  export let descs: Record<string, string> = {}
  export let dirty: boolean
</script>

<section class="mdesc">Đang áp dụng: {descs[xargs.rmode]}</section>
<section class="modes chip-list">
  <span class="chip-text u-show-pl">Đổi chế độ:</span>
  {#each Object.entries(modes) as [mode, label]}
    <a
      class="chip-link _active"
      href={pager.gen_url({ mode: mode })}
      data-tip={descs[mode]}
      data-tip-loc="bottom"
      on:click={() => (dirty = true)}>
      <span>{label}</span>
      {#if xargs.rmode == mode}<SIcon name="check" />{/if}
    </a>
  {/each}
</section>

<style lang="scss">
  .mdesc {
    @include flex-ca($gap: 0.25rem);
    @include fgcolor(mute);
    @include ftsize(sm);
    margin-bottom: 0.25rem;
    font-style: italic;
  }
</style>
