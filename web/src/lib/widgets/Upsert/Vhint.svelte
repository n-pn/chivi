<script context="module">
  function showing(words) {
    if (words < 7) return '_ss'
    if (words < 9) return '_sm'
    if (words < 13) return '_md'
    if (words < 17) return '_lg'
    // if (words < 18) return '_xl'
    return '_xx'
  }
</script>

<script>
  export let hints
  export let value
  export let _orig
  export let trans

  $: hanviet = trans.hanviet || ''
  $: binh_am = trans.binh_am || ''

  $: words = hanviet.split(' ').length * (_hint.length + 2)
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

  {#if binh_am}
    <span class="pinyin {showing(words)}">[{binh_am}]</span>
  {/if}
</div>

<style lang="scss">
  .hints {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
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

  // prettier-ignore
  .pinyin {
    font-style: normal;
    margin-left: auto;
    font-size: rem(12px);
    @include truncate(null);

    &._sm { @include props(display, none, $sm: inline-block); }
    &._md { @include props(display, none, $md: inline-block); }
    &._lg { @include props(display, none, $lg: inline-block); }
    &._xl { @include props(display, none, $xl: inline-block); }
    &._xx { display: none; }
  }
</style>
