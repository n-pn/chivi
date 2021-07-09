<script context="module">
</script>

<script>
  export let hanviet
  export let hints
  export let value
  export let _orig

  $: _hint = hints.filter((x) => x != value)
</script>

<div class="hints">
  <span class="hint" on:click={() => (value = hanviet)}>{hanviet}</span>

  {#each _hint as hint}
    {#if hint != value}
      <span
        class="hint"
        class:_orig={hint == _orig}
        on:click={() => (value = hint)}>{hint}</span>
    {/if}
  {/each}
</div>

<style lang="scss">
  .hints {
    padding: 0.25rem 0.5rem;
    font-style: italic;
    height: 1.75rem;
    line-height: 1.25rem;

    @include flex();
    @include border($sides: bottom);

    @include font-size(2);
    @include fgcolor(neutral, 6);
  }

  .hint {
    cursor: pointer;
    padding: 0 0.25rem;

    @include radius;
    @include truncate(null);

    &:hover {
      @include fgcolor(primary, 6);
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
