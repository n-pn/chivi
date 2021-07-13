<script>
  import SIcon from '$atoms/SIcon.svelte'

  export let phrase = ['', 0, 0]
  export let pinyin = ''
  export let output = ''

  $: [input, lower = 0, upper = input.length] = phrase
  $: prefix = input.substring(lower - 2, lower)
  $: output = input.substring(lower, upper)
  $: suffix = input.substring(upper, upper + 2)

  function move_lower_left() {
    lower -= 1
  }

  function move_lower_right() {
    lower += 1
    if (upper <= lower) upper += 1
  }

  function move_upper_left() {
    upper -= 1
    if (lower >= upper) lower -= 1
  }

  function move_upper_right() {
    upper += 1
  }
</script>

<div class="input">
  <button
    class="_left"
    data-kbd="h"
    disabled={lower == 0}
    on:click={move_lower_left}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="_left"
    data-kbd="j"
    disabled={lower >= input.length - 1}
    on:click={move_lower_right}>
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
    disabled={upper == 1}
    on:click={move_upper_left}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="_right"
    data-kbd="l"
    disabled={upper == input.length}
    on:click={move_upper_right}>
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

    @include bdradi();
    @include bgcolor(neutral, 1);
    @include border($color: neutral, $tone: 3);
  }

  .hanzi {
    flex-grow: 1;
    display: flex;
    justify-content: center;

    overflow: hidden;
    flex-wrap: nowrap;
    @include ftsize(lg);
  }

  ._key {
    font-weight: 500;
    position: relative;
    max-width: 100%;
    line-height: $height - 0.125rem;

    > ._txt {
      @include clamp($width: 20vw);
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

  ._pinyin {
    display: flex;
    justify-content: center;

    position: absolute;
    left: 4.5rem;
    right: 4.5rem;
    bottom: -0.4125rem;
    height: 1rem;

    line-height: 1rem;
    font-size: rem(10px);

    ._text {
      padding: 0 0.25rem;
      display: inline-block;
      @include clamp($width: null);
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
    @include ftsize(lg);
    @include fgcolor(neutral, 7);

    &:hover {
      @include bgcolor(white);
      @include fgcolor(primary, 5);
    }

    &:disabled {
      cursor: pointer;
      @include fgcolor(neutral, 5);
      background: transparent;
    }

    &:first-of-type {
      @include bdradi($sides: left);
    }

    &:last-of-type {
      @include bdradi($sides: right);
    }

    &._left {
      @include border($sides: right);
    }

    &._right {
      @include border($sides: left);
    }
  }
</style>
