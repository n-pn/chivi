<script>
  import { hint, titleize } from './_shared'

  import SIcon from '$atoms/SIcon.svelte'

  export let term

  function upcase_val(node, count) {
    const action = (_) => (term.val = titleize(term.val, count))
    node.addEventListener('click', action)
    return { destroy: () => node.removeEventListener('click', action) }
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
  <button
    class="cap _sm"
    data-kbd="3"
    use:upcase_val={3}
    use:hint={'Viết hoa ba chữ đầu'}>
    <span>H. 3 chữ</span></button>
  <button
    class="cap"
    data-kbd="4"
    use:upcase_val={20}
    use:hint={'Viết hoa tất cả các chữ'}>
    <span>H. tất cả</span></button>
  <button
    class="cap"
    data-kbd="0"
    data-key="192"
    use:upcase_val={0}
    use:hint={'Viết thường tất cả các chữ'}>
    <span>Không hoa</span></button>

  <div class="right">
    <button
      class="btn"
      data-kbd="w"
      disabled={term.val == term.old_val && term.ptag == term.old_ptag}
      on:click={() => (term = term.reset())}
      use:hint={'Phục hồi lại nghĩa + phân loại ban đầu'}>
      <SIcon name="corner-up-left" />
    </button>

    <button
      class="btn"
      data-kbd="e"
      on:click={() => (term = term.clear())}
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

    @include bp-max(sm) { @include ftsize(xs); }
    &:hover { @include fgcolor(primary, 5); }
    &._sm { @include bps(display, none, $sm: inline-block); }
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
