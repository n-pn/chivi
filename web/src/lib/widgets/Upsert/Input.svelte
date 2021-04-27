<script>
  import SIcon from '$lib/blocks/SIcon'

  export let phrase
  export let pinyin
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
    <SIcon name="chevron-left" />
  </button>

  <button
    class="_left"
    disabled={lower == upper - 1}
    on:click={() => (lower += 1)}
    data-kbd="j">
    <SIcon name="chevron-right" />
  </button>

  <div class="hanzi">
    <div class="_key" data-left={prefix} data-right={suffix}>
      <span class="_txt">{output}</span>
    </div>
  </div>

  <button
    class="_right"
    data-kbd="k"
    disabled={upper == lower + 1}
    on:click={() => (upper -= 1)}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="_right"
    disabled={upper == input.length}
    data-kbd="l"
    on:click={() => (upper += 1)}>
    <SIcon name="chevron-right" />
  </button>

  <div class="_pinyin">
    <span class="_text">{pinyin}</span>
  </div>
</div>

<style lang="scss">
  $height: 2.25rem;

  .input {
    display: flex;
    margin: 0 0.25rem;
    width: calc(100% - 5rem);
    height: $height;
    position: relative;

    @include radius();
    @include bgcolor(neutral, 1);
    @include border($color: neutral, $shade: 3);
  }

  .hanzi {
    flex-grow: 1;
    display: flex;
    justify-content: center;

    overflow: hidden;
    flex-wrap: nowrap;
    @include font-size(4);
  }

  ._key {
    font-weight: 500;
    position: relative;
    max-width: 100%;
    line-height: $height - 0.25rem;
    // max-width: 30vw;

    > ._txt {
      @include truncate(20vw);
      @include fgcolor(neutral, 7);
    }

    &:before,
    &:after {
      display: block;
      position: absolute;
      top: 0;
      font-weight: 400;
      height: 100%;
      white-space: nowrap;
      @include fgcolor(neutral, 4);
    }

    &:before {
      content: attr(data-left);
      right: 100%;
    }

    &:after {
      content: attr(data-right);
      left: 100%;
    }
  }

  // .-sub {
  //   @include fgcolor(neutral, 4);
  // }

  ._pinyin {
    display: flex;
    justify-content: center;

    position: absolute;
    left: 4.5rem;
    right: 4.5rem;
    bottom: -0.375rem;
    height: 1rem;

    line-height: 1rem;
    font-size: rem(10px);

    ._text {
      padding: 0 0.25rem;
      display: inline-block;
      @include truncate(null);
      @include fgcolor(neutral, 5);
      @include bgcolor(neutral, 1);
    }
  }

  button {
    background: transparent;
    padding: 0 0.5rem;
    margin: 0;
    line-height: 1em;
    max-width: 65vw;
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

    &:first-child {
      @include radius($sides: left);
    }

    &:last-child {
      @include radius($sides: right);
    }

    &._left {
      @include border($sides: right);
    }

    &._right {
      @include border($sides: left);
    }
  }
</style>
