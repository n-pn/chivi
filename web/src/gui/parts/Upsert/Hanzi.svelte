<script context="module" lang="ts">
  import { ztext, zfrom, zupto } from '$lib/stores'

  const mapper = [
    [0, 0],
    [-1, 0],
    [1, 0],
    [0, 1],
    [0, -1],
    [-2, 0],
    [0, 2],
  ]

  import type { VpTermInit } from '$lib/vp_term'
  import { VpTerm } from '$lib/vp_term'
</script>

<script lang="ts">
  import { hint } from './_shared'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let vpdicts = []
  export let vpterms = []
  export let output = ''
  export let active = true

  let cached = { pin_yin: {} }
  for (const { dname } of vpdicts) cached[dname] = {}

  let prefix = ''
  let suffix = ''

  $: active && update_input($ztext, $zfrom, $zupto, vpdicts)

  async function update_input(
    ztext: string,
    zfrom: number,
    zupto: number,
    dicts: CV.VpDict[]
  ) {
    output = ztext.substring(zfrom, zupto)
    prefix = ztext.substring(zfrom - 10, zfrom)
    suffix = ztext.substring(zupto, zupto + 10)

    let words = mapper.map(([l, r]) => ztext.substring(zfrom + l, zupto + r))
    words = words.filter((x, i, s) => x && s.indexOf(x) == i)
    await update_cached(words, dicts)

    vpterms = vpdicts.map(({ dname }) => cached[dname][output])
    // console.log(vpterms)
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

  async function update_cached(words: string[], dicts: CV.VpDict[]) {
    if (words.length == 0) return

    const input = {
      pin_yin: words.filter((x) => !cached.pin_yin[x]).slice(0, 7),
    }

    for (const { dname } of dicts) {
      cached[dname] = cached[dname] || {}
      input[dname] = words.filter((x) => !cached[dname][x]).slice(0, 4)
    }

    if (input_is_empty(input)) return

    const api_url = `/api/terms/query`
    const api_res = await fetch(api_url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ input }),
    })

    const payload = await api_res.json()
    if (!api_res.ok) return console.log(payload.error)

    for (const dname in payload.props) {
      const terms = payload.props[dname]

      for (const key in terms) {
        const val = terms[key]
        if (dname == 'pin_yin') cached[dname][key] = val as string
        else cached[dname][key] = new VpTerm(val as VpTermInit)
      }
    }
  }

  function input_is_empty(input: Record<string, string[]>) {
    for (const dname in input) {
      if (input[dname].length > 0) return false
    }
    return true
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
    disabled={$zfrom == $ztext.length - 1}
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
    <span class="pinyin-txt">{cached.pin_yin[output] || ''}</span>
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
    disabled={$zupto == $ztext.length}
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
