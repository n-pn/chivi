<script context="module">
  const prios = { H: 'Cao', M: 'Bình', L: 'Thấp' }
  const types = { N: 'Danh', V: 'Động', A: 'Tính' }
</script>

<script>
  export let attrs
  export let dtype

  $: prio = attrs.includes('H') ? 'H' : attrs.includes('L') ? 'L' : 'M'

  function update_prio(val) {
    if (val == 'M') val = ''
    attrs = prio == 'M' ? val + attrs : attrs.replace(prio, val)
  }

  function update_type(attr) {
    attrs = attrs.includes(attr) ? attrs.replace(attr, '') : attrs + attr
  }
</script>

<div class="attrs">
  <div class="-line _prio">
    <span class="-text {dtype < 2 ? '_hide' : ''}">Ưu tiên:</span>
    {#each Object.entries(prios) as [val, lbl]}
      <button
        class="-attr"
        class:active={prio == val}
        data-kbd={val}
        on:click={() => update_prio(val)}>{lbl}</button>
    {/each}
  </div>

  {#if dtype < 2}
    <div class="-line _type">
      <span class="-text _hide">Phân loại:</span>
      {#each Object.entries(types) as [val, lbl]}
        <button
          class="-attr"
          data-kbd={val}
          class:active={attrs.includes(val)}
          on:click={() => update_type(val)}>{lbl}</button>
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
