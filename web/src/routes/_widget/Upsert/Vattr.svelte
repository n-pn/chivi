<script context="module">
  const prios = { H: 'Cao', M: 'Bình', L: 'Thấp' }
  const types = { N: 'Danh', V: 'Động', A: 'Tĩnh' }
</script>

<script>
  export let attrs
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
  <div class="-line">
    {#each Object.entries(prios) as [val, lbl]}
      <button
        class="-attr"
        class:active={prio == val}
        data-kbd={val}
        on:click={() => update_prio(val)}>{lbl}</button>
    {/each}
  </div>

  <div class="-line">
    {#each Object.entries(types) as [val, lbl]}
      <button
        class="-attr"
        data-kbd={val}
        class:active={attrs.includes(val)}
        on:click={() => update_type(val)}>{lbl}</button>
    {/each}
  </div>
</div>

<style lang="scss">
  .attrs {
    position: absolute;
    top: 0;
    right: 0;
    height: 3rem;
    padding: 0.325rem 0.375rem;
  }

  .-line {
    line-height: 1rem;
    width: 7rem;
    font-weight: 500;
    @include flex;
    justify-content: right;

    &:first-child {
      margin-bottom: 0.375rem;
    }
  }

  .-attr {
    cursor: pointer;
    display: inline-block;
    text-align: center;
    padding: 0 0.25rem;
    font-size: rem(10px);
    text-transform: uppercase;

    @include fgcolor(neutral, 5);
    @include bgcolor(neutral, 1);
    @include radius;

    & + & {
      margin-left: 0.25rem;
    }

    &:hover {
      @include fgcolor(primary, 4);
    }

    &.active {
      @include fgcolor(#fff);
      @include bgcolor(primary, 4);
    }
  }
</style>
