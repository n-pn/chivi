<script context="module">
  const priorities = { L: 'Thấp', M: 'Bình', H: 'Cao' }
  const types = { N: 'Danh', V: 'Động', A: 'Tính' }
</script>

<script>
  export let prio = 1
  export let attr = 0
  export let with_types = true
</script>

<div class="attrs">
  <div class="-line _prio">
    <span class="-text" class:_hide={with_types}>Ưu tiên:</span>
    {#each Object.entries(priorities) as [val, lbl], idx}
      <button
        class="-attr"
        class:active={prio == idx}
        data-kbd={val}
        on:click={() => (prio = idx)}>{lbl}</button>
    {/each}
  </div>

  {#if with_types}
    <div class="-line _type">
      <span class="-text _hide">Phân loại:</span>
      {#each Object.entries(types) as [val, lbl], idx}
        <button
          class="-attr"
          data-kbd={val}
          class:active={attr & (1 << idx)}
          on:click={() => (attr = attr ^ (1 << idx))}>{lbl}</button>
      {/each}
    </div>
  {/if}
</div>

<style lang="scss">
  $height: 2.15rem;

  .attrs {
    display: flex;
    margin-top: 0.75rem;
    justify-content: space-evenly;
  }

  .-line {
    @include flex;
  }

  .-text,
  .-attr {
    line-height: 1.5rem;

    font-size: rem(12px);
    text-transform: uppercase;
    font-weight: 500;
    @include fgcolor(neutral, 4);
  }

  .-text {
    margin-right: 0.375rem;
    margin-top: 1px;

    &._hide {
      @include props(display, none, $md: inline-block);
    }
  }

  .-attr {
    cursor: pointer;

    padding: 0 0.375rem;
    background-color: #fff;
    @include fgcolor(neutral, 5);

    @include border();
    @include radius(0.5rem);

    &:hover,
    &.active {
      @include bdcolor(primary, 4);
    }

    &.active {
      @include fgcolor(primary, 5);
    }

    & + & {
      margin-left: 0.375rem;
    }
  }
</style>
