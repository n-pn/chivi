<script>
  import { tag_label } from '$lib/pos_tag.js'

  export let vpterm
  export let hints

  $: ptag_priv = get_ptag(vpterm, '_priv')
  $: ptag_base = get_ptag(vpterm, '_base')
  $: ptag_hint = ptag_priv || ptag_base || vpterm._priv.ptag || ''

  function get_ptag(vpterm, type) {
    const orig = vpterm[type]
    return orig.mtime < 0 || orig.ptag == vpterm.ptag ? null : orig.ptag
  }
</script>

<div class="hints">
  {#each hints as hint, idx (hint)}
    {#if (idx == 0 || hint != vpterm.val.trim()) && hint}
      <button
        class="hint"
        class:_base={vpterm._base.mtime >= 0 && hint == vpterm._base.val}
        class:_priv={vpterm._priv.mtime >= 0 && hint == vpterm._priv.val}
        on:click={() => (vpterm.val = hint)}>{hint}</button>
    {/if}
  {/each}

  {#if ptag_hint != vpterm.ptag}
    <button
      class="hint _ptag"
      class:_base={ptag_hint == ptag_base}
      class:_priv={ptag_hint == ptag_priv}
      on:click={() => (vpterm.ptag = ptag_hint)}>{tag_label(ptag_hint)}</button>
  {/if}
</div>

<style lang="scss">
  .hints {
    padding: 0 0.5rem;
    height: 2rem;

    @include flex($gap: 0.125rem);
    @include ftsize(sm);
  }

  // prettier-ignore
  .hint {
    cursor: pointer;
    padding: 0.25rem;
    line-height: 1.5rem;
    background-color: inherit;
    @include fgcolor(tert);

    @include bdradi;
    @include clamp($width: null);

    &._ptag {
      margin-left: auto;
      font-size: rem(13px);
    }

    &._priv, &._base { @include fgcolor(secd); }
    &._priv { font-weight: 500; }
    &._base { font-style: italic; }

    @include hover { @include fgcolor(primary, 5); }
  }
</style>
