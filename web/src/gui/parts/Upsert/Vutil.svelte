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
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { hint, type VpForm } from './_shared'

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
        data-kbd="r"
        disabled={form.val == form.init.val && form.ptag == form.init.ptag}
        on:click={() => (form = form.reset())}
        use:hint={'Phục hồi lại nghĩa + phân loại ban đầu'}>
        <SIcon name="corner-up-left" />
      </button>

      <button
        class="btn"
        data-kbd="e"
        disabled={!form.val && !form.ptag}
        on:click={() => (form = form.clear())}
        use:hint={'Xoá nghĩa từ / Xoá phân loại'}>
        <SIcon name="eraser" />
      </button>
    </div>
  </div>
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
