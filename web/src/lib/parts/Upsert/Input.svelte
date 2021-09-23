<script>
  import SIcon from '$atoms/SIcon.svelte'

  export let phrase = ['', 0, 0]
  export let pinyin = ''
  export let output = ''

  $: [input, lower = 0, upper = input.length] = phrase
  $: output = input.substring(lower, upper)
  $: prefix = Array.from(input.substring(lower - 3, lower))
  $: suffix = Array.from(input.substring(upper, upper + 3))

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
    disabled={lower >= input.length - 1}
    on:click={move_lower_right}>
    <SIcon name="chevron-right" />
  </button>

  <button
    class="_left"
    data-kbd="j"
    disabled={lower == 0}
    on:click={move_lower_left}>
    <SIcon name="chevron-left" />
  </button>

  <div class="key">
    <div class="key-txt" data-right={suffix}>
      <span class="key-out">{output}</span>
      <span class="key-pre">
        {#each prefix as chr, idx}
          <span class="key-btn" on:click={() => (lower -= prefix.length - idx)}
            >{chr}</span>
        {/each}
      </span>
      <span class="key-suf">
        {#each suffix as chr, idx}
          <span class="key-btn" on:click={() => (upper += idx + 1)}>{chr}</span>
        {/each}
      </span>
    </div>
  </div>

  <button
    class="_right"
    data-kbd="k"
    disabled={upper == input.length}
    on:click={move_upper_right}>
    <SIcon name="chevron-right" />
  </button>

  <button
    class="_right"
    data-kbd="l"
    disabled={upper == 1}
    on:click={move_upper_left}>
    <SIcon name="chevron-left" />
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
    @include bgcolor(tert);
    @include linesd(--bd-soft);
  }

  .key {
    flex-grow: 1;
    display: flex;
    justify-content: center;

    overflow: hidden;
    flex-wrap: nowrap;
    @include ftsize(xl);
  }

  .key-txt {
    font-weight: 500;
    position: relative;
    max-width: 100%;
    line-height: $height;
  }

  .key-out {
    @include clamp($width: 20vw);
    @include fgcolor(main);
  }

  .key-pre,
  .key-suf {
    display: block;
    position: absolute;
    top: 0;
    font-weight: 400;
    height: 100%;
    white-space: nowrap;
    @include fgcolor(mute);
  }

  .key-pre {
    right: 100%;
  }

  .key-suf {
    left: 100%;
  }

  .key-btn {
    cursor: pointer;
    @include hover {
      @include fgcolor(tert);
    }
  }

  ._pinyin {
    display: flex;
    justify-content: center;

    position: absolute;
    left: 4.5rem;
    right: 4.5rem;
    top: -0.5rem;
    height: 1rem;

    line-height: 1rem;
    font-size: rem(10px);

    ._text {
      padding: 0 0.25rem;
      display: inline-block;
      @include clamp($width: null);
      @include fgcolor(tert);
      @include bgcolor(tert);
    }
  }

  button {
    background: transparent;
    padding: 0 0.5rem;
    margin: 0;
    line-height: 1em;
    max-width: 65vw;
    @include ftsize(lg);
    @include fgcolor(secd);

    &:hover {
      // @include bgcolor(tert);
      @include fgcolor(primary, 5);
    }

    &:disabled {
      cursor: pointer;
      @include fgcolor(neutral, 5);
      background: transparent;
    }

    &:first-of-type {
      @include bdradi($loc: left);
    }

    &:last-of-type {
      @include bdradi($loc: right);
    }

    &._left {
      @include border(--bd-soft, $loc: right);
    }

    &._right {
      @include border(--bd-soft, $loc: left);
    }
  }
</style>
