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
    class="-txt"
    data-kbd="1"
    use:upcase_val={1}
    use:hint={'Viết hoa một chữ đầu'}>Hoa 1 chữ</button>
  <button
    class="-txt"
    data-kbd="2"
    use:upcase_val={2}
    use:hint={'Viết hoa hai chữ đầu'}>H. 2 chữ</button>
  <button
    class="-txt _md"
    data-kbd="3"
    use:upcase_val={3}
    use:hint={'Viết hoa ba chữ đầu'}>H. 3 chữ</button>
  <button
    class="-txt"
    data-kbd="4"
    use:upcase_val={20}
    use:hint={'Viết hoa tất cả các chữ'}>H. tất cả</button>
  <button
    class="-txt"
    data-kbd="0"
    data-key="192"
    use:upcase_val={0}
    use:hint={'Viết thường tất cả các chữ'}>Không hoa</button>

  <div class="right">
    <button
      class="-btn"
      data-kbd="r"
      disabled={term.val == term.old_val && term.ptag == term.old_ptag}
      on:click={() => (term = term.reset())}
      use:hint={'Phục hồi lại nghĩa + phân loại ban đầu'}>
      <SIcon name="corner-up-left" />
    </button>

    <button
      class="-btn"
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

  .-txt {
    padding: 0 0.375rem;
    line-height: $height;
    font-weight: 500;
    background: transparent;
    @include fgcolor(tert);

    @include bps(font-size, rem(13px), rem(14px));
    @include bp-max(sm) {
      @include ftsize(xs);
    }
    // max-width: 14vw;
    @include clamp($width: null);

    &:hover {
      @include fgcolor(primary, 5);
    }

    &._md {
      @include bps(display, none, $md: inline-block);
    }
  }

  .-btn {
    margin-left: auto;
    padding: 0;
    width: 1.75rem;
    padding-bottom: 0.25rem;

    @include ftsize(lg);

    background: transparent;
    @include fgcolor(neutral, 5);

    &:hover {
      @include fgcolor(primary, 5);
    }

    &[disabled] {
      @include fgcolor(neutral, 3);
    }
  }
</style>
