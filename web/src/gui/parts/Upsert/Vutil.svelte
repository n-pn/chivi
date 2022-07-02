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

  import type { VpTerm } from '$lib/vp_term'
</script>

<script lang="ts">
  import { hint } from './_shared'
  import { gtran, btran } from '$lib/trans'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let key: string
  export let tab = 0
  export let vpterm: VpTerm

  let capped = 0
  let length = 0

  $: [capped, length] = check_capped(vpterm.val)

  let gtran_lang = [0, 0, 0] // gtran lang index for each tab
  let btran_lang = [0, 0, 0] // bing tran lang index for each tab
  $: if (key) {
    gtran_lang = [0, 0, 0]
    btran_lang = [0, 0, 0]
  }

  function upcase_val(node: Element, count: number) {
    const action = (_: any) => {
      if (count != capped) {
        vpterm.val = titleize(vpterm.val, count)
        capped = count
      } else {
        vpterm.val = detitle(vpterm.val, count)
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

  async function load_gtran(text: string) {
    vpterm.val = '...'

    try {
      const res = await gtran(text, gtran_lang[tab])
      const [capped, length] = check_capped(res)

      if (tab == 2 && capped == 2 && length == 2) {
        // swap first name and last name if result is a japanese name
        const [fname, lname] = res.split(' ')
        vpterm.val = lname + ' ' + fname
      } else if (capped > 1 || tab == 0) {
        // keep res format if it is a name or in book dict tab
        vpterm.val = res
      } else {
        vpterm.val = res.toLowerCase()
      }

      gtran_lang[tab] = (gtran_lang[tab] + 1) % 3
      gtran_lang = gtran_lang

      // vpterm = vpterm
    } catch (err) {
      alert(err)
    }
  }

  async function load_btran(text: string) {
    vpterm.val = '...'

    const res = await btran(text, btran_lang[tab])
    vpterm.val = res

    btran_lang[tab] = (btran_lang[tab] + 1) % 2
  }
</script>

<div class="vutil">
  <button
    class="cap"
    class:_actived={capped == 1}
    data-kbd="1"
    use:upcase_val={1}
    use:hint={'Viết hoa một chữ đầu'}>
    <span>V. hoa 1</span>
  </button>

  <button
    class="cap"
    class:_actived={capped == 2}
    data-kbd="2"
    use:upcase_val={2}
    use:hint={'Viết hoa hai chữ đầu'}>
    <span>V. hoa 2</span>
  </button>

  <button
    class="cap _show-ts"
    data-kbd="3"
    class:_actived={capped == 3}
    use:upcase_val={3}
    use:hint={'Viết hoa ba chữ đầu'}>
    <span>V. hoa 3</span>
  </button>

  <button
    class="cap _show-pl"
    data-kbd="4"
    disabled={capped == length}
    use:upcase_val={99}
    use:hint={'Viết hoa tất cả các chữ'}>
    <span>V.hoa tất</span>
  </button>

  <button
    class="cap _show-pl"
    disabled={vpterm.val == vpterm.val.toLowerCase()}
    data-kbd="0"
    data-key="Backquote"
    use:upcase_val={0}
    use:hint={'Viết thường tất cả các chữ'}>
    <span>Không v. hoa</span>
  </button>

  <div class="right">
    <button
      class="btn _{gtran_lang[tab]}"
      data-kbd="t"
      on:click={() => load_gtran(key)}
      use:hint={'Dịch bằng Google Translate sang Anh/Việt'}>
      <SIcon name="language" />
    </button>

    <button
      class="btn _{btran_lang[tab]}"
      data-kbd="y"
      on:click={() => load_btran(key)}
      use:hint={'Dịch bằng Bing Translate sang Anh/Việt'}>
      <SIcon name="brand-bing" />
    </button>

    <button
      class="btn"
      data-kbd="r"
      disabled={vpterm.val == vpterm.o_val && vpterm.ptag == vpterm.o_ptag}
      on:click={() => (vpterm = vpterm.reset())}
      use:hint={'Phục hồi lại nghĩa + phân loại ban đầu'}>
      <SIcon name="corner-up-left" />
    </button>

    <button
      class="btn"
      data-kbd="e"
      on:click={() => (vpterm = vpterm.clear())}
      use:hint={'Bấm hai lần nếu bạn muốn xoá đè.'}>
      <SIcon name="eraser" />
    </button>
  </div>
</div>

<style lang="scss">
  $height: 2.25rem;

  .vutil {
    padding: 0 0.375rem;
    @include flex($gap: 0);
  }

  .right {
    @include flex();
    margin-left: auto;
  }

  .btn,
  .cap {
    background: transparent;
    @include fgcolor(tert);
  }

  // prettier-ignore
  .cap {
    line-height: $height;
    font-weight: 500;

    @include bps(font-size, rem(13px), rem(14px));
    @include bps(padding, 0 0.25rem, 0 0.375rem);

    @include bp-max(pl) { @include ftsize(xs); }

    > span { @include clamp($width: null); }

    &:disabled { @include fgcolor(mute); }
    &._actived { @include fgcolor(primary, 5); }
    &._show-ts { @include bps(display, none, $ts: inline-block); }
    &._show-pl:disabled { @include bps(display, none, $pl: inline-block); }
  }

  // prettier-ignore
  .btn {
    margin-left: auto;
    width: 1.75rem;
    height: $height;
    position: relative;
    // padding: 0;
    // padding-bottom: 0.125rem;
    @include ftsize(lg);

    &[disabled] { @include fgcolor(mute); }
    &._1 { @include fgcolor(primary, 5); }
    &._2 { @include fgcolor(harmful, 5); }
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
