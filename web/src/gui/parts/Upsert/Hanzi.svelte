<script context="module" lang="ts">
  import { ztext, zfrom, zupto } from '$lib/stores'
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let output = ''
  export let pinyin = ''

  let prefix = ''
  let suffix = ''

  $: update_input($ztext, $zfrom, $zupto)

  const update_input = (text: string, from: number, upto: number) => {
    output = text.substring(from, upto)
    prefix = text.substring(from - 10, from)
    suffix = text.substring(upto, upto + 10)
  }

  function change_focus(index: number) {
    if (index != $zfrom && index < $zupto) $zfrom = index
    if (index >= $zfrom) $zupto = index + 1
  }

  function shift_lower(value = 0) {
    value += $zfrom
    if (value < 0 || value >= $ztext.length) return

    $zfrom = value
    if ($zupto <= value) $zupto = value + 1
  }

  function shift_upper(value = 0) {
    value += $zupto
    if (value < 1 || value > $ztext.length) return

    $zupto = value
    if ($zfrom >= value) $zfrom = value - 1
  }
</script>

<div class="ztext">
  <button
    class="btn _left _hide"
    data-kbd="←"
    disabled={$zfrom == 0}
    on:click={() => shift_lower(-1)}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="btn _left"
    data-kbd="⇧←"
    disabled={$zfrom == $ztext.length - 1}
    on:click={() => shift_lower(1)}>
    <SIcon name="chevron-right" />
  </button>

  <div class="key">
    <div class="key-txt">
      <div class="key-pre">
        {#each Array.from(prefix) as chr, idx}
          {@const offset = prefix.length - idx}
          <button class="key-btn" on:click={() => shift_lower(-offset)}
            >{chr}</button>
        {/each}
      </div>

      <div class="key-out">
        {#each output.slice(0, 6) as chr, idx}
          <button
            class="key-btn _out"
            on:click={() => change_focus($zfrom + idx)}>{chr}</button>
        {/each}
        {#if output.length > 6}
          <span class="trim">(+{output.length - 6})</span>
        {/if}
      </div>

      <div class="key-suf">
        {#each Array.from(suffix) as chr, idx}
          {@const offset = idx + 1}
          <button class="key-btn" on:click={() => shift_upper(offset)}
            >{chr}</button>
        {/each}
      </div>
    </div>
  </div>

  <div class="pinyin">
    <span class="pinyin-txt">{pinyin}</span>
  </div>

  <button
    class="btn _right"
    data-kbd="⇧→"
    disabled={$zupto == 1}
    on:click={(e) => shift_upper(-1)}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="btn _right _hide"
    data-kbd="→"
    disabled={$zupto == $ztext.length}
    on:click={(e) => shift_upper(1)}>
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
    position: relative;
    max-width: 100%;
    line-height: $height;
    font-family: var(--font-sans);
  }

  .trim {
    @include fgcolor(tert);
    font-size: rem(16px);
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

    &._out {
      font-weight: 500;
      @include fgcolor(primary, 5);
    }
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
