<script>
  export let hints
  export let value
  export let _orig

  export let hanviet = ''
</script>

<div class="hints">
  <span class="hint" on:click={() => (value = hanviet)}>
    {hanviet}
  </span>

  {#each hints as hint}
    {#if hint != value}
      <span
        class="hint"
        class:_orig={hint == _orig}
        on:click={() => (value = hint)}>{hint}</span>
    {/if}
  {/each}

  <span class="_right">
    {#if value != _orig}
      <button class="-btn" data-kbd="r" on:click={() => (value = _orig)}
        >Phục</button>
    {/if}
    <button class="-btn" data-kbd="e" on:click={() => (value = '')}>Xoá</button>
  </span>
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

    @include border($sides: bottom);
    @include flex();
  }

  .hint {
    cursor: pointer;

    padding: 0 0.25rem;
    @include font-size(2);

    @include truncate(null);
    @include radius;

    @include fgcolor(neutral, 6);
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

  ._right {
    margin-left: auto;
  }

  .-btn {
    float: left;
    padding: 0 0.375rem;
    font-weight: 500;
    text-transform: uppercase;
    @include font-size(1);
    background: none;
    @include fgcolor(neutral, 5);

    &:hover {
      @include fgcolor(primary, 5);
    }
  }
</style>
