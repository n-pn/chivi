<script>
  export let term
  export let hints
</script>

<div class="hints">
  {#each hints as hint, idx}
    {#if idx == 0 || hint != term.val}
      <span
        class="hint"
        class:_orig={hint == term._priv.val || hint == term._base.val}
        on:click={() => (term.val = hint)}>{hint}</span>
    {/if}
  {/each}
</div>

<style lang="scss">
  .hints {
    padding: 0.25rem 0.5rem;
    font-style: italic;
    height: 2rem;
    line-height: 1.5rem;

    @include flex();
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  .hint {
    cursor: pointer;
    padding: 0 0.25rem;

    @include bdradi;
    @include clamp($width: null);

    &:hover {
      @include fgcolor(primary, 5);
    }

    & + & {
      margin-left: 0.375rem;
    }
  }

  ._orig {
    font-style: normal;
    font-weight: 500;
  }
</style>
