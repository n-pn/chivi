<script>
  import { tag_label } from '$lib/pos_tag.js'

  export let term
  export let hints

  $: ptag_priv = get_ptag(term, '_priv')
  $: ptag_base = get_ptag(term, '_base')
  $: ptag_hint = ptag_priv || ptag_base || ''

  function get_ptag(term, type) {
    const orig = term[type]
    return orig.mtime < 0 || orig.ptag == term.ptag ? null : orig.ptag
  }
</script>

<div class="hints">
  {#each hints as hint, idx}
    {#if idx == 0 || hint != term.old_val}
      <button
        class="hint"
        class:_orig={hint == term.old_val}
        on:click={() => (term.val = hint)}>{hint}</button>
    {/if}
  {/each}

  {#if ptag_hint}
    <button
      class="hint _ptag"
      class:_base={ptag_hint == ptag_base}
      class:_priv={ptag_hint == ptag_priv}
      on:click={() => (term.ptag = ptag_hint)}>{tag_label(ptag_hint)}</button>
  {/if}
</div>

<style lang="scss">
  .hints {
    padding: 0.25rem 0.5rem;
    height: 2rem;

    @include flex($gap: 0.25rem);
    @include ftsize(sm);
  }

  .hint {
    cursor: pointer;
    padding: 0 0.25rem;
    line-height: 1.5rem;
    background-color: inherit;
    @include fgcolor(tert);

    @include bdradi;
    @include clamp($width: null);

    &:hover {
      @include fgcolor(primary, 5);
    }

    &._ptag {
      margin-left: auto;
      @include ftsize(xs);
    }

    &._orig {
      font-style: italic;
      // font-style: normal;
      // font-weight: 500;
    }

    &._priv {
      font-weight: 500;
      @include fgcolor(secd);
    }

    &._base {
      font-style: italic;
    }
  }
</style>
