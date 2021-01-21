<script>
  export let trans
  export let hints
  export let value
  export let _orig
</script>

<div class="hints">
  <span class="hint" on:click={() => (value = trans.hanviet)}>
    {trans.hanviet}
  </span>

  {#each hints as hint}
    {#if hint != value}
      <span
        class="hint"
        class:_orig={hint == _orig}
        on:click={() => (value = hint)}>{hint}</span>
    {/if}
  {/each}

  <span class="hint _right">[{trans.binh_am}]</span>
</div>

<style lang="scss">
  .hints {
    width: 100%;
    padding: 0.25rem 0.5rem;
    font-style: italic;

    @include flex();
    @include font-size(2);
  }

  .hint {
    cursor: pointer;
    line-height: 1.5rem;
    height: 1.5rem;
    padding: 0 0.25rem;

    @include truncate(null);
    @include radius;

    @include fgcolor(neutral, 6);

    &:hover {
      @include fgcolor(primary, 6);
    }

    & + & {
      margin-left: 0.25rem;
    }

    &._right {
      margin-left: auto;
    }
  }

  ._orig {
    font-style: normal;
    // font-weight: 500;
  }
</style>
