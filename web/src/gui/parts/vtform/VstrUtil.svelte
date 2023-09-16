<script context="module" lang="ts">
  export function titleize(str: string, count = 9) {
    if (!str) return ''
    if (typeof count == 'boolean') count = count ? 9 : 0

    const res = str.split(' ')
    if (count > res.length) count = res.length

    for (let i = 0; i < count; i++) res[i] = capitalize(res[i])
    for (let i = count; i < res.length; i++) res[i] = res[i].toLowerCase()

    return res.join(' ')
  }

  export function capitalize(str: String) {
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  function detitle(str: String, count = 9) {
    const res = str.split(' ')
    if (count > res.length) count = res.length
    for (let i = 0; i < count; i++) res[i] = res[i].toLowerCase()
    for (let i = count; i < res.length; i++) res[i] = capitalize(res[i])

    return res.join(' ')
  }
</script>

<script lang="ts">
  import { tooltip } from '$lib/actions'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import { gtran, btran, deepl } from '$utils/qtran_utils'

  import type { Vtform } from '$lib/models/viterm'

  export let tform: Vtform
  export let field: HTMLInputElement
  export let refocus: (caret: number) => void

  let capped = 0
  let length = 0

  $: [capped, length] = check_capped(tform.vstr)

  $: vstr_nocap = tform.vstr.toLowerCase()

  let show_trans = false

  function trigger_trans_submenu() {
    show_trans = !show_trans
    if (field) field.focus()
  }

  function upcase_vstr(node: Element, count: number) {
    const action = (_: any) => {
      if (count != capped) {
        tform.vstr = titleize(tform.vstr, count)
        capped = count
      } else {
        tform.vstr = detitle(tform.vstr, count)
        capped = 0
      }
    }

    node.addEventListener('click', action)
    return { destroy: () => node.removeEventListener('click', action) }
  }

  function check_capped(vstr: string) {
    const words = vstr.split(' ')

    let capped: number
    for (capped = 0; capped < words.length; capped++) {
      const word = words[capped]
      if (word != capitalize(word)) break
    }

    return [capped, words.length]
  }

  function toggle_cap_all() {
    const caret = field.selectionStart

    if (tform.vstr != vstr_nocap) tform.vstr = vstr_nocap
    else tform.vstr = titleize(tform.vstr, 999)

    setTimeout(refocus, 20, caret)
  }

  function toggle_cap_one() {
    console.log(field.selectionStart)
    // field.focus()
    // TODO
  }

  async function run_gtran(tab = 0) {
    field.focus()
    tform.vstr = '...'
    tform.vstr = await gtran(tform.init.zstr, tab)
  }

  async function run_btran(tab = 0) {
    field.focus()
    tform.vstr = '...'
    tform.vstr = await btran(tform.init.zstr, tab, true)
  }

  async function run_deepl(tab = 0) {
    field.focus()
    tform.vstr = '...'
    tform.vstr = await deepl(tform.init.zstr, tab, false)
  }
</script>

<div hidden>
  {#each [1, 2, 3] as num}
    <button
      class="btn _{num}"
      class:_active={capped == num}
      data-kbd={num}
      use:upcase_vstr={num}
      use:tooltip={`Viết hoa ${num} chữ đầu`}
      data-anchor=".vtform">
      <span class="cap">V.hoa {num}</span>
    </button>
  {/each}

  <button
    class="btn"
    data-kbd="4"
    disabled={capped == length}
    use:upcase_vstr={99}
    use:tooltip={'Viết hoa tất cả các chữ'}
    data-anchor=".vtform">
    <span class="cap">V.hoa tất</span>
  </button>

  <button
    class="btn"
    disabled={tform.vstr == tform.vstr.toLowerCase()}
    data-kbd="0"
    data-key="Backquote"
    use:upcase_vstr={0}
    use:tooltip={'Viết thường tất cả các chữ'}
    data-anchor=".vtform">
    <span class="cap">Viết thường</span>
  </button>
</div>

<div class="wrap">
  <button
    class="btn _tl"
    class:_active={tform.vstr == tform.init.hviet}
    on:click={() => (tform.vstr = tform.init.hviet)}
    data-tip="Điền nghĩa Hán Việt">
    <SIcon name="letter-h" />
    <span class="lang">V</span>
  </button>

  <span class="sep" />

  <button
    class="btn _tl"
    data-kbd="5"
    on:click={() => run_gtran(0)}
    use:tooltip={'Dịch bằng Google từ Trung sang Việt'}
    data-anchor=".vtform">
    <SIcon name="brand-google" />
    <span class="lang">V</span>
  </button>

  <button
    class="btn _tl"
    data-kbd="6"
    on:click={() => run_btran(0)}
    use:tooltip={'Dịch bằng Bing từ Trung sang Việt'}
    data-anchor=".vtform">
    <SIcon name="brand-bing" />
    <span class="lang">V</span>
  </button>

  <span class="sep" />

  <button
    class="btn _tl"
    on:click={() => run_gtran(1)}
    use:tooltip={'Dịch bằng Google từ Trung sang Anh'}
    data-anchor=".vtform">
    <SIcon name="brand-google" />
    <span class="lang">E</span>
  </button>

  <button
    class="btn _tl"
    on:click={() => run_btran(1)}
    use:tooltip={'Dịch bằng Bing từ Trung sang Anh'}
    data-anchor=".vtform">
    <SIcon name="brand-bing" />
    <span class="lang">E</span>
  </button>

  <button
    class="btn _tl"
    on:click={() => run_deepl(0)}
    use:tooltip={'Dịch bằng DeepL từ Trung sang Anh'}
    data-anchor=".vtform">
    <img src="/icons/deepl.svg" alt="deepl" />
    <span class="lang">E</span>
    <!-- <span class="lang">DE</span> -->
  </button>

  <span class="sep" />

  <button
    class="btn _tl _optional"
    on:click={() => run_gtran(2)}
    use:tooltip={'Dịch bằng Google từ Nhật sang Anh'}
    data-anchor=".vtform">
    <SIcon name="brand-google" />
    <span class="lang">J</span>
  </button>

  <button
    class="btn _tl _optional"
    on:click={() => run_btran(2)}
    use:tooltip={'Dịch bằng Bing từ Nhật sang Anh'}
    data-anchor=".vtform">
    <SIcon name="brand-bing" />
    <span class="lang">J</span>
  </button>

  <button
    class="btn _tl _optional"
    on:click={() => run_deepl(1)}
    use:tooltip={'Dịch bằng DeepL từ Nhật sang Anh'}
    data-anchor=".vtform">
    <img src="/icons/deepl.svg" alt="deepl" />
    <span class="lang">J</span>
    <!-- <span class="lang">DE</span> -->
  </button>

  <div class="right">
    <button
      class="btn"
      data-kbd="a"
      on:click={toggle_cap_all}
      use:tooltip={'Viết hoa/Viết thường tất cả các chữ'}
      data-anchor=".vtform">
      <SIcon
        name="letter-case-{tform.vstr == vstr_nocap ? 'upper' : 'lower'}" />
    </button>

    <button
      class="btn"
      data-kbd="s"
      on:click={toggle_cap_one}
      use:tooltip={'Viết hoa/Viết thường chữ tại vị trí caret'}
      data-anchor=".vtform">
      <SIcon name="letter-case-toggle" />
    </button>

    <button
      class="btn"
      data-kbd="r"
      on:click={() => (tform = tform.reset())}
      use:tooltip={'Phục hồi lại nghĩa + phân loại ban đầu'}
      data-anchor=".vtform">
      <SIcon name="corner-up-left" />
    </button>

    <button
      class="btn"
      data-kbd="e"
      on:click={() => (tform = tform.clear())}
      use:tooltip={'Xoá nghĩa từ / Xoá phân loại'}
      data-anchor=".vtform">
      <SIcon name="eraser" />
    </button>
  </div>
</div>

<style lang="scss">
  $height: 2.25rem;

  .wrap {
    display: flex;
    position: relative;
    padding: 0 0.375rem;
    @include bps(font-size, rem(12px), $pm: rem(13px), $ts: rem(14px));
  }

  .sep {
    margin-right: 0.125em;
    padding-right: 0.125em;

    $sep-height: 1rem;
    height: $sep-height;
    $margin: math.div($height - $sep-height, 2);

    margin-top: $margin;
    margin-bottom: $margin;

    @include border($loc: right);
  }

  // .left {
  //   display: inline-flex;
  //   align-items: center;
  //   flex-shrink: 1;
  //
  //   min-width: 280px;
  // }

  .right {
    display: inline-flex;
    margin-left: auto;
  }

  .btn {
    display: inline-flex;
    flex-wrap: nowrap;
    align-items: center;
    padding: 0 0.325em;
    // font-weight: 500;

    background: none;
    @include fgcolor(tert);

    gap: 0.125rem;

    height: $height;
    // position: relative;
    // padding: 0;
    // padding-bottom: 0.125rem;
    :global(svg) {
      font-size: 1rem;
    }

    &._active,
    &:hover {
      @include fgcolor(primary, 5);
    }

    &[disabled] {
      @include fgcolor(mute);
    }

    &._optional {
      @include bps(display, none, $pl: inline-flex);
    }
  }

  .btn._tl {
    img {
      display: inline-block;
      // width: rem(12px);
      opacity: 0.6;
      width: 0.8em;
      height: auto;
      margin-right: 0.05rem;
    }

    :global(svg) {
      width: 0.9em;
      // height: 0.9em;
      margin-top: -0.05em;
      margin-right: -0.05em;
    }

    span {
      @include fgcolor(secd);
    }
  }
</style>
