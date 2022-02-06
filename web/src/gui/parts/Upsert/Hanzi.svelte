<script context="module">
  import { call_api } from '$api/_api_call'
  import { vdict, ztext, zfrom, zupto } from '$lib/stores'

  function make_word_list(ztext, lower, upper) {
    const words = [ztext.substring(lower, upper)]

    if (lower > 0) words.push(ztext.substring(lower - 1, upper))
    if (lower + 1 < upper) words.push(ztext.substring(lower + 1, upper))

    if (upper - 1 > lower) words.push(ztext.substring(lower, upper - 1))
    if (upper + 1 < ztext.length) words.push(ztext.substring(lower, upper + 1))
    if (upper + 2 < ztext.length) words.push(ztext.substring(lower, upper + 2))
    if (upper + 3 < ztext.length) words.push(ztext.substring(lower, upper + 3))

    if (lower > 1) words.push(ztext.substring(lower - 2, upper))

    return words
  }
</script>

<script>
  import { hint, decor_term } from './_shared'
  import SIcon from '$atoms/SIcon.svelte'

  export let vpterms = []
  export let valhint = []
  export let output = ''

  let cached_vpterms = {}
  let cached_valhint = {}
  let cached_pin_yin = {}
  let prefix = ''
  let suffix = ''

  $: update_input($ztext, $zfrom, $zupto)

  async function update_input(ztext, zfrom, zupto) {
    output = ztext.substring(zfrom, zupto)
    prefix = ztext.substring(zfrom - 10, zfrom)
    suffix = ztext.substring(zupto, zupto + 10)

    let words = make_word_list(ztext, zfrom, zupto)
    words = words.filter((x) => x && !cached_vpterms[x])

    if (words.length > 0) {
      const url = `dicts/${$vdict.dname}/search`
      const [err, res] = await call_api(fetch, url, { words })
      if (err) return console.log({ err, res })

      for (const inp in res) {
        const data = res[inp]

        cached_pin_yin[inp] = data.pin_yin
        cached_valhint[inp] = data.val_hint

        cached_vpterms[inp] = [
          decor_term(data.special),
          decor_term(data.regular),
          decor_term(data.hanviet),
        ]
      }
    }

    vpterms = cached_vpterms[output] || []
    valhint = cached_valhint[output] || []
  }

  function change_focus(index) {
    if (index != $zfrom && index < $zupto) $zfrom = index
    if (index >= $zfrom) $zupto = index + 1
  }

  function shift_lower(value = 0) {
    value += $zfrom
    if (value < 0 || value >= ztext.length) return

    $zfrom = value
    if ($zupto <= value) $zupto = value + 1
  }

  function shift_upper(value = 0) {
    value += $zupto
    if (value < 1 || value > ztext.length) return

    $zupto = value
    if ($zfrom >= value) $zfrom = value - 1
  }
</script>

<div class="ztext">
  <button
    class="btn _left _hide"
    data-kbd="←"
    use:hint={'Mở rộng sang trái'}
    disabled={$zfrom == 0}
    on:click={() => shift_lower(-1)}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="btn _left"
    data-kbd="⇧←"
    use:hint={'Thu hẹp từ trái'}
    disabled={$zfrom == ztext.length - 1}
    on:click={() => shift_lower(1)}>
    <SIcon name="chevron-right" />
  </button>

  <div class="key">
    <div class="key-txt">
      <div class="key-pre">
        {#each Array.from(prefix) as chr, idx}
          <button
            class="key-btn"
            use:hint={'Mở rộng sang trái'}
            on:click={() => ($zfrom -= prefix.length - idx)}>{chr}</button>
        {/each}
      </div>

      <div class="key-out">
        {#each output.slice(0, 6) as chr, idx}
          <button
            class="key-btn _out"
            use:hint={'Thu hẹp về ký tự này'}
            on:click={() => change_focus($zfrom + idx)}>{chr}</button>
        {/each}
        {#if output.length > 6}
          <span class="trim">(+{output.length - 6})</span>
        {/if}
      </div>

      <div class="key-suf">
        {#each Array.from(suffix) as chr, idx}
          <button
            class="key-btn"
            use:hint={'Mở rộng sang phải'}
            on:click={() => ($zupto += idx + 1)}>{chr}</button>
        {/each}
      </div>
    </div>
  </div>

  <div class="pinyin">
    <span class="pinyin-txt">{cached_pin_yin[output] || ''}</span>
  </div>

  <button
    class="btn _right"
    data-kbd="⇧→"
    use:hint={'Thu hẹp từ phải'}
    disabled={$zupto == 1}
    on:click={() => shift_upper(-1)}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="btn _right _hide"
    data-kbd="→"
    use:hint={'Mở rộng sang phải'}
    disabled={$zupto == ztext.length}
    on:click={() => shift_upper(1)}>
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
