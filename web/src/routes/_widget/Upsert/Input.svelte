<script>
  import SvgIcon from '$atoms/SvgIcon'

  export let phrase
  export let output
  export let binh_am = ''

  $: [input, lower, upper] = phrase
  $: prefix = input.substring(lower - 2, lower)
  $: output = input.substring(lower, upper)
  $: suffix = input.substring(upper, upper + 2)
</script>

<div class="input">
  <button
    class="_left"
    disabled={lower == 0}
    data-kbd="h"
    on:click={() => (lower -= 1)}>
    <SvgIcon name="chevron-left" />
  </button>

  <button
    class="_left"
    disabled={lower == upper - 1}
    on:click={() => (lower += 1)}
    data-kbd="j">
    <SvgIcon name="chevron-right" />
  </button>

  <div class="hanzi">
    <span class="-sub">{prefix}</span>
    <span class="-key">{output}</span>
    <span class="-sub">{suffix}</span>
    <span class="-lit"><span class="-val">[{binh_am}]</span></span>
  </div>

  <button
    class="_right"
    data-kbd="k"
    disabled={upper == lower + 1}
    on:click={() => (upper -= 1)}>
    <SvgIcon name="chevron-left" />
  </button>

  <button
    class="_right"
    disabled={upper == input.length}
    data-kbd="l"
    on:click={() => (upper += 1)}>
    <SvgIcon name="chevron-right" />
  </button>
</div>

<style lang="scss">
  $height: 2.25rem;

  .input {
    display: flex;
    width: 100%;
    height: $height;

    @include radius();
    @include bgcolor(neutral, 1);
    @include border($color: neutral, $shade: 3);
  }

  .hanzi {
    flex-grow: 1;
    display: flex;
    justify-content: center;
    line-height: 2rem;
    position: relative;
    // white-space: nowrap;
    @include font-size(4);
  }

  .-key {
    font-weight: 500;
    max-width: 8rem;
    @include fgcolor(neutral, 7);
    @include truncate(null);
  }

  .-sub {
    @include fgcolor(neutral, 4);
  }

  .-lit {
    position: absolute;
    text-align: center;
    left: 0;
    top: 1.625rem;
    width: 100%;
    line-height: 1rem;
  }

  .-val {
    display: inline-block;
    padding: 0 0.25rem;
    max-width: 100%;
    @include radius;
    @include truncate(null);
    @include bgcolor(neutral, 1);
    @include font-size(1);
    @include fgcolor(neutral, 6);
  }

  button {
    background: transparent;
    padding: 0 0.5rem;
    margin: 0;
    line-height: 1em;
    @include font-size(4);
    @include fgcolor(neutral, 7);

    &:hover {
      background-color: #fff;
      @include fgcolor(primary, 5);
    }

    &:disabled {
      cursor: pointer;
      @include fgcolor(neutral, 5);
      background: transparent;
    }

    &._left {
      @include border($sides: right);
    }

    &._right {
      @include border($sides: left);
    }
  }
</style>
