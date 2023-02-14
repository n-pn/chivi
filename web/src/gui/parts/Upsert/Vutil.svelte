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
  import { hint, VpForm } from './_shared'
  import { gtran, btran, deepl } from '$lib/trans'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let key: string
  export let tab = 0

  export let form: VpForm
  export let refocus = () => {}

  let capped = 0
  let length = 0

  $: [capped, length] = check_capped(form.val)

  let show_trans = false

  function trigger_trans_submenu() {
    show_trans = !show_trans
    refocus()
  }

  function upcase_val(node: Element, count: number) {
    const action = (_: any) => {
      if (count != capped) {
        form.val = titleize(form.val, count)
        capped = count
      } else {
        form.val = detitle(form.val, count)
        capped = 0
      }
    }

    node.addEventListener('click', action)
    return { destroy: () => node.removeEventListener('click', action) }
  }

  function check_capped(val: string) {
    const words = val.split(' ')

    let capped: number
    for (capped = 0; capped < words.length; capped++) {
      const word = words[capped]
      if (word != capitalize(word)) break
    }

    return [capped, words.length]
  }

  async function load_gtran(key: string, g_tab = 0) {
    form.val = '...'
    refocus()

    const tran = await gtran(key, g_tab)

    if (tab == 2) {
      const [fname, lname] = tran.split(' ')
      form.val = lname + ' ' + fname
    } else {
      form.val = tran
    }

    show_trans = false
  }

  async function load_btran(b_tab = 0) {
    form.val = '...'
    refocus()

    const lang = b_tab == 0 ? 'vi' : 'en'
    form.val = await btran(key, lang, true)

    show_trans = false
  }

  async function load_deepl() {
    form.val = '...'
    refocus()

    form.val = await deepl(key, false)
    show_trans = false
  }
</script>

<div class="wrap">
  <div class="vutil">
    {#each [1, 2, 3] as num}
      {@const icon = 'letter-case' + (capped == num ? '-toggle' : '')}
      <button
        class="btn"
        data-kbd={num}
        use:upcase_val={num}
        use:hint={`Viết hoa ${num} chữ đầu`}>
        <SIcon name={icon} />
        <span class="cap">{num}</span>
        <span class="lbl">chữ</span>
      </button>
    {/each}

    <button
      class="btn"
      data-kbd="4"
      disabled={capped == length}
      use:upcase_val={99}
      use:hint={'Viết hoa tất cả các chữ'}>
      <SIcon name="letter-case-upper" />
      <span class="lbl">V.hoa</span>
      <span class="cap">tất</span>
    </button>

    <button
      class="btn"
      disabled={form.val == form.val.toLowerCase()}
      data-kbd="0"
      data-key="Backquote"
      use:upcase_val={0}
      use:hint={'Viết thường tất cả các chữ'}>
      <SIcon name="letter-case-lower" />
      <span class="lbl">Viết</span>
      <span class="cap">thường</span>
    </button>

    <div class="right">
      <button
        class="btn"
        class:_active={show_trans}
        data-kbd="t"
        on:click={trigger_trans_submenu}
        use:hint={'Dịch bằng Google Translate sang Anh/Việt'}>
        <SIcon name="language" />
      </button>

      <button
        class="btn"
        data-kbd="r"
        disabled={form.val == form.init.val && form.tag == form.init.ptag}
        on:click={() => (form = form.reset())}
        use:hint={'Phục hồi lại nghĩa + phân loại ban đầu'}>
        <SIcon name="corner-up-left" />
      </button>

      <button
        class="btn"
        data-kbd="e"
        disabled={!form.val && !form.tag}
        on:click={() => (form = form.clear())}
        use:hint={'Xoá nghĩa từ / Xoá phân loại'}>
        <SIcon name="eraser" />
      </button>
    </div>
  </div>

  {#if show_trans}
    <div class="trans">
      <button
        class="btn"
        data-kbd="5"
        on:click={() => load_gtran(key, 0)}
        use:hint={'Dịch bằng Google từ Trung sang Anh'}>
        <SIcon name="brand-google" />
        <span class="lang">Anh</span>
      </button>

      <button
        class="btn"
        data-kbd="6"
        on:click={() => load_gtran(key, 1)}
        use:hint={'Dịch bằng Google từ Trung sang Việt'}>
        <SIcon name="brand-google" />
        <span class="lang">Việt</span>
      </button>

      <button
        class="btn"
        data-kbd="7"
        on:click={() => load_gtran(key, 2)}
        use:hint={'Dịch tên riêng tiếng Nhật bằng Google Dịch'}>
        <SIcon name="brand-google" />
        <span class="lang">Nhật</span>
      </button>

      <button
        class="btn"
        data-kbd="9"
        on:click={() => load_deepl()}
        use:hint={'Dịch bằng DeepL từ Trung sang Anh'}>
        <span class="lang">DeepL</span>
      </button>

      <button
        class="btn"
        data-kbd="8"
        on:click={() => load_btran(0)}
        use:hint={'Dịch bằng Bing từ Trung sang Việt'}>
        <SIcon name="brand-bing" />
        <span class="lang">Việt</span>
      </button>

      <button
        class="btn"
        data-kbd="9"
        on:click={() => load_btran(1)}
        use:hint={'Dịch bằng Bing từ Trung sang Anh'}>
        <SIcon name="brand-bing" />
        <span class="lang">Anh</span>
      </button>
    </div>
  {/if}
</div>

<style lang="scss">
  $height: 2.25rem;

  .wrap {
    position: relative;
  }

  .vutil {
    padding: 0 0.375rem;
    @include flex($gap: 0);
    min-width: 280px;
  }

  .trans {
    @include flex($gap: 0);
    @include bgcolor(secd);
    @include border();
    @include bdradi($loc: bottom);

    z-index: 99999;
    left: 0;
    right: 0;
    top: 2rem;
    position: absolute;
    justify-content: flex-end;

    padding: 0 0.375rem;

    > .btn {
      height: 2rem;
      font-size: rem(13px);

      :global(svg) {
        @include ftsize(sm);
      }
    }
  }

  .lbl {
    display: none;
    font-size: rem(14px);
    // @include fgcolor(mute);
    @include bps(display, none, $ts: inline-block);
  }

  .right {
    @include flex();
    margin-left: auto;
  }

  .btn {
    background: transparent;
    @include fgcolor(tert);
  }

  .cap {
    font-size: rem(14px);
  }

  .btn {
    display: inline-flex;
    align-items: center;
    padding: 0 0.25rem;
    font-weight: 500;

    gap: 0.125rem;

    height: $height;
    // position: relative;
    // padding: 0;
    // padding-bottom: 0.125rem;
    :global(svg) {
      font-size: 1rem;
    }

    &[disabled] {
      @include fgcolor(mute);
    }
    &._active {
      @include fgcolor(primary, 5);
    }
  }

  // .lang {
  //   position: absolute;
  //   display: inline-block;

  //   bottom: 0.25rem;
  //   right: -0.125rem;
  //   line-height: 0.75rem;
  //   width: 0.75rem;
  //   text-align: center;
  //   font-size: 9px;
  //   font-weight: 500;
  //   text-transform: uppercase;
  //   border-radius: 0.125rem;
  //   // @include border();
  //   @include linesd(--bd-main, $inset: false);
  // }
</style>
