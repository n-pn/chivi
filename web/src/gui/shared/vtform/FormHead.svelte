<script lang="ts">
  import { Rdword, type Rdline } from '$lib/reader'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { copy_to_clipboard } from '$utils/btn_utils'

  export let actived = true

  export let rline: Rdline
  export let rword: Rdword

  $: chars = Array.from(rline.ztext)
  $: zsize = chars.length

  $: [pre_chars, out_chars, suf_chars] = split_ztext(chars, rword)

  function split_ztext(chars: string[], { from, upto }) {
    let zmin = from - 10
    if (zmin < 0) zmin = 0

    return [
      chars.slice(zmin, from),
      chars.slice(from, upto),
      chars.slice(upto, upto + 10),
    ]
  }

  function change_index(index: number) {
    let { from, upto } = rword
    if (index != from && index < upto) from = index
    if (index >= from) upto = index + 1
    rword = new Rdword(from, upto, 'X')
  }

  function shift_lower(value = 0) {
    value += rword.from
    if (value < 0 || value >= zsize) return
    rword = new Rdword(value, rword.upto <= value ? value + 1 : rword.upto, 'X')
  }

  function shift_upper(value = 0) {
    value += rword.upto
    if (value < 1 || value > zsize) return
    rword = new Rdword(rword.from >= value ? value - 1 : rword.from, value, 'X')
  }
</script>

<header class="head">
  <button
    class="m-btn _text"
    data-kbd="⌃c"
    disabled={out_chars.length == 0}
    on:click={() => copy_to_clipboard(out_chars.join(''))}>
    <SIcon name="copy" />
  </button>

  <button
    class="btn _left"
    data-kbd="←"
    disabled={rword.from == 0}
    on:click={() => shift_lower(-1)}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="btn _left"
    data-kbd="⇧←"
    disabled={rword.from == zsize - 1}
    on:click={() => shift_lower(1)}>
    <SIcon name="chevron-right" />
  </button>

  <div class="main">
    <div class="ztxt">
      <div class="zpre">
        {#each pre_chars as chr, idx}
          <button
            type="button"
            class="key-btn"
            on:click={() => shift_lower(-pre_chars.length + idx)}>{chr}</button>
        {/each}
      </div>

      <div class="-zut">
        {#each out_chars.slice(0, 6) as chr, idx}
          <button
            class="key-btn _out"
            type="button"
            on:click={() => change_index(rword.from + idx)}>{chr}</button>
        {/each}
        {#if out_chars.length > 6}
          <span class="trim">(+{out_chars.length - 6})</span>
        {/if}
      </div>

      <div class="zsuf">
        {#each suf_chars as chr, idx}
          <button
            type="button"
            class="key-btn"
            on:click={() => shift_upper(idx + 1)}>{chr}</button>
        {/each}
      </div>
    </div>
    <div class="hlit">
      <span>{rline.get_hviet(rword.from, rword.upto)}</span>
    </div>
  </div>

  <button
    class="btn _right"
    data-kbd="⇧→"
    disabled={rword.upto == 1}
    on:click={(e) => shift_upper(-1)}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="btn _right"
    data-kbd="→"
    disabled={rword.upto == zsize}
    on:click={(e) => shift_upper(1)}>
    <SIcon name="chevron-right" />
  </button>

  <button
    type="button"
    class="m-btn _text"
    data-kbd="esc"
    on:click={() => (actived = false)}>
    <SIcon name="x" />
  </button>
</header>

<style lang="scss">
  $height: 2.25rem;
  $mwidth: 1.875rem;

  .head {
    position: relative;
    display: flex;
    @include border(--bd-soft, $loc: bottom);
  }

  .m-btn {
    @include fgcolor(neutral, 5);
    background: none;
    --linesd: none;

    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .btn {
    background: transparent;
    margin: 0;
    line-height: 1em;

    width: $mwidth;
    @include flex-ca;
    // max-width: 65vw;

    @include ftsize(lg);
    @include fgcolor(secd);

    &._left {
      @include border(--bd-soft, $loc: left);
    }

    &._right {
      @include border(--bd-soft, $loc: right);
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

  .main {
    @include flex-cx;
    flex-grow: 1;

    overflow: hidden;
    flex-wrap: nowrap;

    font-size: rem(20px);
    font-family: var(--font-sans);
    @include border(--bd-soft, $loc: left-right);
  }

  .ztxt {
    @include flex-cx;
    position: relative;
    max-width: 100%;
    height: $height;
    line-height: $height;
    background-color: inherit;
  }

  .trim {
    @include fgcolor(tert);
    font-size: rem(16px);
  }

  .zpre,
  .zsuf {
    display: block;
    position: absolute;
    font-weight: 400;
    top: 0;
    height: 100%;
    white-space: nowrap;
    @include fgcolor(mute);
  }

  .zpre {
    right: 100%;
  }

  .zsuf {
    left: 100%;
  }

  .hlit {
    display: flex;
    justify-content: center;
    position: absolute;
    left: 0;
    right: 0;
    bottom: -0.5rem;
    height: 1rem;

    line-height: 1rem;
    font-size: rem(13px);

    @include fgcolor(tert);

    > span {
      padding: 0 0.25rem;
      @include bgcolor(tert);
      @include clamp($width: null);
    }
  }

  .trim {
    @include fgcolor(tert);
    font-size: rem(16px);
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

    @include hover {
      @include fgcolor(primary, 5);
    }
  }
</style>
