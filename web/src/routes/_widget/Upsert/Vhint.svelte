<script>
  export let hints
  export let value
  export let _orig
  export let trans

  $: hanviet = trans.hanviet || ''
  $: binh_am = trans.binh_am || ''
</script>

<div class="hints">
  <span class="hint" on:click={() => (value = hanviet)}>{hanviet}</span>

  {#each hints as hint}
    {#if hint != value}
      <span
        class="hint"
        class:_orig={hint == _orig}
        on:click={() => (value = hint)}>{hint}</span>
    {/if}
  {/each}

  <span class="right">[{binh_am}]</span>
</div>

<style lang="scss">
  .hints {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    padding: 0.375rem 0.5rem;
    font-style: italic;
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
    @include bgcolor(neutral, 1);

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

  .right {
    font-style: normal;
    margin-left: auto;
    font-size: rem(12px);
    @include truncate(null);
  }
</style>
