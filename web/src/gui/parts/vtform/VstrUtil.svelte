<script context="module" lang="ts">
  export function capitalize(str: String) {
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  export function titleize(str: string, count = 9) {
    if (!str) return ''
    if (typeof count == 'boolean') count = count ? 9 : 0

    const res = str.split(' ')
    if (count > res.length) count = res.length

    for (let i = 0; i < count; i++) res[i] = capitalize(res[i])
    for (let i = count; i < res.length; i++) res[i] = res[i].toLowerCase()

    return res.join(' ')
  }

  function detitleize(str: String, count = 9) {
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

  $: vstr_lower = tform.vstr.toLowerCase()
  $: vstr_upper = titleize(tform.vstr, 999)

  let show_hints = false
  let show_trans = false
  let show_caps = false

  $: if (tform.vstr) {
    show_hints = false
    show_trans = false
    show_caps = false
  }

  function upcase_vstr(node: Element, count: number) {
    const action = (_: any) => {
      if (count != capped) {
        tform.vstr = titleize(tform.vstr, count)
        capped = count
      } else {
        tform.vstr = detitleize(tform.vstr, count)
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

  function to_upper(count = 99) {
    const caret = field.selectionStart
    tform.vstr = titleize(tform.vstr, count)

    refocus(caret)
  }

  function to_lower(count = 99) {
    const caret = field.selectionStart
    tform.vstr = detitleize(tform.vstr, count)

    refocus(caret)
  }

  function toggle_cap_one() {
    console.log(field.selectionStart)
    // field.focus()
    // TODO
  }

  async function run_gtran(tab = 0) {
    field.focus()
    tform.vstr = await gtran(tform.init.zstr, tab)
  }

  async function run_btran(tab = 0) {
    field.focus()
    tform.vstr = await btran(tform.init.zstr, tab, true)
  }

  async function run_deepl(tab = 0) {
    field.focus()
    tform.vstr = await deepl(tform.init.zstr, tab, false)
  }
</script>

<div class="util">
  <div class="util-main">
    <button
      class="btn _tl"
      class:_active={tform.vstr == tform.init.hviet}
      on:click={() => (tform.vstr = tform.init.hviet)}
      use:tooltip={'Điền vào cụm từ Hán Việt'}
      data-anchor=".vtform">
      <SIcon name="letter-h" />
      <span class="lang">V</span>
    </button>

    <button
      class="btn _tl"
      on:click={() => (show_hints = !show_hints)}
      use:tooltip={'Thêm các gợi ý dịch nghĩa đã có sẵn'}
      data-anchor=".vtform"
      disabled>
      <SIcon name="letter-v" />
      <SIcon name="caret-down" />
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
      on:click={() => run_deepl(0)}
      use:tooltip={'Dịch bằng DeepL từ Trung sang Anh'}
      data-anchor=".vtform">
      <img src="/icons/deepl.svg" alt="deepl" />
      <span class="lang">E</span>
    </button>
    <button
      class="btn"
      class:_active={show_trans}
      data-kbd="s"
      on:click={() => (show_trans = !show_trans)}
      use:tooltip={'Thêm các lựa chọn dịch ngoài'}
      data-anchor=".vtform">
      <SIcon name="language" />
      <SIcon name="caret-down" />
    </button>

    <div class="right">
      <button
        class="btn"
        class:_active={tform.vstr == vstr_upper}
        data-kbd="a"
        on:click={() => to_upper(999)}
        use:tooltip={'Viết hoa tất cả các chữ'}
        data-anchor=".vtform">
        <SIcon name="letter-case-upper" />
      </button>

      <button
        class="btn"
        class:_active={tform.vstr == vstr_lower}
        data-kbd="s"
        on:click={() => to_lower(999)}
        use:tooltip={'Viết thường tất cả các chữ'}
        data-anchor=".vtform">
        <SIcon name="letter-case-lower" />
      </button>

      <button
        class="btn"
        class:_active={show_caps}
        data-kbd="s"
        on:click={() => (show_caps = !show_caps)}
        use:tooltip={'Thêm các lựa chọn viết hoa/thường'}
        data-anchor=".vtform">
        <SIcon name="letter-case" />
        <SIcon name="caret-down" />
      </button>

      <span class="sep" />

      <button
        class="btn"
        data-kbd="e"
        on:click={() => (tform = tform.clear())}
        use:tooltip={'Xoá nghĩa từ / Xoá phân loại'}
        data-anchor=".vtform">
        <SIcon name="eraser" />
      </button>

      <button
        class="btn"
        data-kbd="r"
        on:click={() => (tform = tform.reset())}
        use:tooltip={'Phục hồi lại nghĩa + phân loại ban đầu'}
        data-anchor=".vtform">
        <SIcon name="corner-up-left" />
      </button>
    </div>
  </div>

  <div class="util-more" class:_active={show_trans}>
    <button
      class="btn _tl"
      on:click={() => run_gtran(1)}
      use:tooltip={'Dịch bằng Google từ Trung sang Anh'}
      data-anchor=".vtform">
      <SIcon name="brand-google" />
      <span class="lang">Anh</span>
    </button>
    <button
      class="btn _tl"
      on:click={() => run_btran(1)}
      use:tooltip={'Dịch bằng Bing từ Trung sang Anh'}
      data-anchor=".vtform">
      <SIcon name="brand-bing" />
      <span class="lang">Anh</span>
    </button>

    <span class="sep" />

    <button
      class="btn _tl"
      on:click={() => run_gtran(2)}
      use:tooltip={'Dịch bằng Google từ Nhật sang Anh'}
      data-anchor=".vtform">
      <SIcon name="brand-google" />
      <span class="lang">Nhật</span>
    </button>

    <button
      class="btn _tl"
      on:click={() => run_btran(2)}
      use:tooltip={'Dịch bằng Bing từ Nhật sang Anh'}
      data-anchor=".vtform">
      <SIcon name="brand-bing" />
      <span class="lang">Nhật</span>
    </button>

    <button
      class="btn _tl"
      on:click={() => run_deepl(1)}
      use:tooltip={'Dịch bằng DeepL từ Nhật sang Anh'}
      data-anchor=".vtform">
      <img src="/icons/deepl.svg" alt="deepl" />
      <span class="lang">Nhật</span>
      <!-- <span class="lang">DE</span> -->
    </button>
  </div>

  <div class="util-more _right" class:_active={show_caps}>
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
  </div>
</div>

<style lang="scss">
  $height: 2.25rem;

  .util {
    position: relative;
  }

  .util-main {
    @include flex-cy;
    position: relative;
    padding: 0 0.375rem;
    height: $height;

    @include bps(font-size, rem(12px), $pm: rem(13px), $ts: rem(14px));
  }

  .util-more {
    display: none;
    position: absolute;
    top: 100%;
    margin-top: -4px;
    left: 0;
    right: 0;
    padding: 0 0.375rem;
    line-height: 1.875rem;
    height: 1.875rem;

    @include bgcolor(main);
    @include ftsize(sm);
    @include border;
    @include bdradi($loc: bottom);

    &._active {
      @include flex-cy;
    }

    &._right {
      justify-content: end;
    }
  }

  .sep {
    margin-right: 0.125em;
    padding-right: 0.125em;

    $sep-height: 1rem;
    height: $sep-height;

    // $margin: math.div($height - $sep-height, 2);
    // margin-top: $margin;
    // margin-bottom: $margin;

    @include border($loc: right);
    @include bps(display, none, $pl: inline);
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
    padding: 0 0.3em;
    // font-weight: 500;

    height: 100%;
    background: none;
    @include fgcolor(tert);

    gap: 0.125rem;

    // position: relative;
    // padding: 0;
    // padding-bottom: 0.125rem;
    :global(svg) {
      font-size: 1rem;
    }

    :global(svg + svg) {
      margin-left: -0.325rem;
    }

    &._active,
    &:hover {
      @include fgcolor(primary, 5);
    }

    &[disabled] {
      @include fgcolor(mute);
    }
  }

  .btn._tl {
    img {
      display: inline-block;
      // width: rem(12px);
      opacity: 0.7;
      width: 0.9em;
      height: auto;
      margin-right: 0.05rem;
    }

    :global(svg) {
      width: 0.9em;
      // height: 0.9em;
      margin-top: -0.05em;
      margin-right: -0.05em;
    }
  }
</style>
