<script>
  import { tag_label } from '$lib/pos_tag.js'

  export let term
  export let hints

  $: ptag_priv = get_ptag(term, '_priv')
  $: ptag_base = get_ptag(term, '_base')
  $: ptag_hint = ptag_priv || ptag_base || term._priv.ptag

  function get_ptag(term, type) {
    const orig = term[type]
    return orig.mtime < 0 || orig.ptag == term.ptag ? null : orig.ptag
  }
</script>

<div class="hints">
  {#each hints as hint, idx}
    {#if (idx == 0 || hint != term.val) && hint}
      <button
        class="hint"
        class:_base={term._base.mtime >= 0 && hint == term._base.val}
        class:_priv={term._priv.mtime >= 0 && hint == term._priv.val}
        on:click={() => (term.val = hint)}>{hint}</button>
    {/if}
  {/each}

  {#if ptag_hint != term.ptag}
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

    @include flex($gap: 0);
    @include ftsize(sm);
  }

  // prettier-ignore
  .hint {
    cursor: pointer;
    padding: 0 0.25rem;
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

    @include hover {
      @include fgcolor(primary, 5);
    }
  }
</style>
