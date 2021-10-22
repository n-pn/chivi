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
  import SIcon from '$atoms/SIcon.svelte'

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
</script>

<div class="vutil">
  <button
    class="cap"
    data-kbd="1"
    use:upcase_val={1}
    use:hint={'Viết hoa một chữ đầu'}>
    <span>Hoa 1 chữ</span></button>
  <button
    class="cap"
    data-kbd="2"
    use:upcase_val={2}
    use:hint={'Viết hoa hai chữ đầu'}>
    <span>H. 2 chữ</span></button>
  {#if length > 3}
    <button
      class="cap"
      data-kbd="3"
      use:upcase_val={3}
      use:hint={'Viết hoa ba chữ đầu'}>
      <span>H. 3 chữ</span></button>
  {/if}
  {#if capped < length}
    <button
      class="cap"
      data-kbd="4"
      use:upcase_val={20}
      use:hint={'Viết hoa tất cả các chữ'}>
      <span>H. tất cả</span></button>
  {/if}
  {#if vpterm.val != vpterm.val.toLowerCase()}
    <button
      class="cap"
      data-kbd="0"
      data-key="192"
      use:upcase_val={0}
      use:hint={'Viết thường tất cả các chữ'}>
      <span>Không hoa</span></button>
  {/if}

  <div class="right">
    <button
      class="btn"
      data-kbd="w"
      disabled={vpterm.val == vpterm.old_val && vpterm.ptag == vpterm.old_ptag}
      on:click={() => (vpterm = vpterm.reset())}
      use:hint={'Phục hồi lại nghĩa + phân loại ban đầu'}>
      <SIcon name="corner-up-left" />
    </button>

    <button
      class="btn"
      data-kbd="e"
      on:click={() => (vpterm = vpterm.clear())}
      use:hint={'Nhập nghĩa là <code>[[pass]]</code> nếu bạn muốn xoá đè.'}>
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
    &:hover { @include fgcolor(primary, 5); }
    > span { @include clamp($width: null); }
  }

  .btn {
    margin-left: auto;
    width: 1.75rem;
    height: $height;
    // padding: 0;
    // padding-bottom: 0.125rem;
    @include ftsize(lg);

    &:hover {
      @include fgcolor(primary, 5);
    }

    &[disabled] {
      @include fgcolor(mute);
    }
  }
</style>
