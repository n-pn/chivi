<script context="module">
  import { create_input } from '$utils/create_stores'
  export const input = create_input()
</script>

<script>
  import { hint } from './_shared'
  import SIcon from '$atoms/SIcon.svelte'

  export let pinyin = ''
  export let output = ''

  let prefix = []
  let suffix = []
  $: [output, prefix, suffix] = update($input)

  function update({ ztext, lower, upper }) {
    const output = ztext.substring(lower, upper)
    const prefix = Array.from(ztext.substring(lower - 10, lower))
    const suffix = Array.from(ztext.substring(upper, upper + 10))
    return [output, prefix, suffix]
  }

  function move_lower_left() {
    $input.lower -= 1
  }

  function move_lower_right() {
    $input.lower += 1
    if ($input.upper <= $input.lower) $input.upper += 1
  }

  function move_upper_left() {
    $input.upper -= 1
    if ($input.lower >= $input.upper) $input.lower -= 1
  }

  function move_upper_right() {
    $input.upper += 1
  }
</script>

<div class="ztext">
  <button
    class="btn _left _hide"
    data-kbd="h"
    use:hint={'Mở rộng sang trái'}
    disabled={$input.lower == 0}
    on:click={move_lower_left}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="btn _left"
    data-kbd="j"
    use:hint={'Thu hẹp từ trái'}
    disabled={$input.lower >= $input.ztext.length - 1}
    on:click={move_lower_right}>
    <SIcon name="chevron-right" />
  </button>

  <div class="key">
    <div class="key-txt">
      <div class="key-pre">
        {#each prefix as chr, idx}
          <button
            class="key-btn"
            use:hint={'Mở rộng sang trái'}
            on:click={() => ($input.lower -= prefix.length - idx)}
            >{chr}</button>
        {/each}
      </div>

      <div class="key-out">
        {#each output.slice(0, 6) as chr, idx}
          <button
            class="key-btn"
            use:hint={'Thu hẹp về ký tự này'}
            on:click={() => (
              ($input.lower += idx), ($input.upper = $input.lower + 1)
            )}>{chr}</button>
        {/each}
        {#if output.length > 6}
          <span class="trim">(+{output.length - 6})</span>
        {/if}
      </div>

      <div class="key-suf">
        {#each suffix as chr, idx}
          <button
            class="key-btn"
            use:hint={'Mở rộng sang phải'}
            on:click={() => ($input.upper += idx + 1)}>{chr}</button>
        {/each}
      </div>
    </div>
  </div>

  <div class="pinyin">
    <span class="pinyin-txt">{pinyin || '--'}</span>
  </div>

  <button
    class="btn _right"
    data-kbd="k"
    use:hint={'Thu hẹp từ phải'}
    disabled={$input.upper == 1}
    on:click={move_upper_left}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="btn _right _hide"
    data-kbd="l"
    use:hint={'Mở rộng sang phải'}
    disabled={$input.upper == $input.ztext.length}
    on:click={move_upper_right}>
    <SIcon name="chevron-right" />
  </button>
</div>

<style lang="scss">
  $height: 2.25rem;

  .ztext {
    display: flex;
    width: calc(100% - 4.5rem);
    height: $height;
    position: relative;
    background-color: inherit;
  }

  .key {
    flex-grow: 1;
    display: flex;
    justify-content: center;

    overflow: hidden;
    flex-wrap: nowrap;
    font-size: rem(20px);
    @include border(--bd-main, $loc: left-right);
  }

  .key-txt {
    font-weight: 500;
    position: relative;
    max-width: 100%;
    line-height: $height;
    > * {
      display: inline;
    }
  }

  .trim {
    @include fgcolor(tert);
    font-size: rem(16px);
  }

  .key-out {
    font-weight: 500;
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
    display: inline-block;
    padding: 0;
    margin: 0;
    min-width: 0.5em;
    text-align: center;
    color: inherit;
    background: transparent;

    // prettier-ignore
    // @include hover { @include fgcolor(primary, 5); }
  }

  .pinyin {
    display: flex;
    justify-content: center;

    position: absolute;
    left: 4.25rem;
    right: 4.25rem;
    bottom: -0.45rem;
    height: 1rem;

    line-height: 1rem;
    font-size: rem(10px);
  }

  .pinyin-txt {
    padding: 0 0.25rem;
    display: inline-block;
    @include clamp($width: null);
    @include fgcolor(tert);
    @include bgcolor(tert);
  }

  .btn {
    background: transparent;
    padding: 0 0.5rem;
    margin: 0;
    line-height: 1em;
    max-width: 65vw;

    @include ftsize(lg);
    @include fgcolor(secd);

    &._left {
      @include border(--bd-main, $loc: left);
    }

    &._right {
      @include border(--bd-main, $loc: right);
    }

    &._hide {
      @include bps(display, none, $pl: inline-block);
    }

    &:hover {
      // @include bgcolor(tert);
      @include fgcolor(primary, 5);
    }

    &:disabled {
      cursor: pointer;
      @include fgcolor(neutral, 5);
      background: transparent;
    }
  }
</style>
