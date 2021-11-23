<script context="module">
  export function titleize(str, count = 9) {
    if (!str) return ''
    if (typeof count == 'boolean') count = count ? 9 : 0

    const res = str.split(' ')
    if (count > res.length) count = res.length

    for (let i = 0; i < count; i++) res[i] = capitalize(res[i])
    for (let i = count; i < res.length; i++) res[i] = res[i].toLowerCase()

    return res.join(' ')
  }

  export function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  function detitle(str, count = 9) {
    const res = str.split(' ')
    if (count > res.length) count = res.length
    for (let i = 0; i < count; i++) res[i] = res[i].toLowerCase()
    for (let i = count; i < res.length; i++) res[i] = capitalize(res[i])

    return res.join(' ')
  }
</script>

<script>
  import { hint } from './_shared'
  import { gtran } from '$utils/gtran.js'

  import SIcon from '$atoms/SIcon.svelte'

  export let key
  export let tab = 0
  export let vpterm

  let capped = 0
  let length = 0

  $: [capped, length] = check_capped(vpterm.val)

  function upcase_val(node, count) {
    const action = (_) => {
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

  function check_capped(val) {
    const words = val.split(' ')

    let capped
    for (capped = 0; capped < words.length; capped++) {
      const word = words[capped]
      if (word != capitalize(word)) break
    }

    return [capped, words.length]
  }

  const lang = [0, 0, 0] // lang index for each tab

  async function load_gtran(text) {
    try {
      const res = await gtran(text, lang[tab])
      const [capped, length] = check_capped(res)

      if (lang == 2 && capped == 2 && length == 2) {
        // swap first name and last name if result is a japanese name
        const [fname, lname] = res.split(' ')
        vpterm.val = lname + ' ' + fname
      } else if (capped > 1 || tab == 0) {
        // keep res format if it is a name or in book dict tab
        vpterm.val = res
      } else {
        vpterm.val = res.toLowerCase()
      }

      lang[tab] = (lang[tab] + 1) % 3

      // vpterm = vpterm
    } catch (err) {
      console.log(err)
    }
  }
</script>

<div class="vutil">
  <button
    class="cap"
    class:_actived={capped == 1}
    data-kbd="1"
    disabled={length < 1}
    use:upcase_val={1}
    use:hint={'Viết hoa một chữ đầu'}>
    <span>V. hoa 1</span>
  </button>
  <button
    class="cap"
    class:_actived={capped == 2}
    data-kbd="2"
    disabled={length < 2}
    use:upcase_val={2}
    use:hint={'Viết hoa hai chữ đầu'}>
    <span>V. hoa 2</span>
  </button>
  <button
    class="cap _show-ts"
    data-kbd="3"
    class:_actived={capped == 3}
    disabled={length < 3}
    use:upcase_val={3}
    use:hint={'Viết hoa ba chữ đầu'}>
    <span>V. hoa 3</span>
  </button>

  <button
    class="cap _show-pl"
    data-kbd="4"
    disabled={capped == length}
    use:upcase_val={20}
    use:hint={'Viết hoa tất cả các chữ'}>
    <span>V.hoa tất</span>
  </button>

  <button
    class="cap _show-pl"
    disabled={vpterm.val == vpterm.val.toLowerCase()}
    data-kbd="0"
    data-key="192"
    use:upcase_val={0}
    use:hint={'Viết thường tất cả các chữ'}>
    <span>Không v. hoa</span>
  </button>

  <div class="right">
    <button
      class="btn _{lang[tab]}"
      data-kbd="t"
      on:click={() => load_gtran(key)}
      use:hint={'Dịch bằng Google Translate sang Anh/Việt'}>
      <SIcon name="language" />
    </button>

    <button
      class="btn"
      data-kbd="w"
      disabled={vpterm.val == vpterm.o_val && vpterm.ptag == vpterm.o_ptag}
      on:click={() => (vpterm = vpterm.reset())}
      use:hint={'Phục hồi lại nghĩa + phân loại ban đầu'}>
      <SIcon name="corner-up-left" />
    </button>

    <button
      class="btn"
      data-kbd="e"
      on:click={() => (vpterm = vpterm.clear())}
      use:hint={'Nhập nghĩa là [[pass]] nếu bạn muốn xoá đè.'}>
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
