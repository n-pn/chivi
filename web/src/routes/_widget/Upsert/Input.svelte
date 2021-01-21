<script>
  import SvgIcon from '$atoms/SvgIcon'

  export let phrase
  export let output

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
    line-height: $height;
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
