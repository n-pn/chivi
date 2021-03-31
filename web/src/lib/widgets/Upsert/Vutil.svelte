<script>
  import { titleize } from '$utils/text_utils'
  import SIcon from '$lib/blocks/SIcon'

  export let value
  export let _orig

  function upcase_val(node, count) {
    const handle_click = (_) => (value = titleize(value, count))
    node.addEventListener('click', handle_click)

    return {
      destroy: () => node.removeEventListener('click', handle_click),
    }
  }
</script>

<div class="vutil">
  <button class="-txt" data-kbd="1" use:upcase_val={1}>Hoa 1 chữ</button>
  <button class="-txt" data-kbd="2" use:upcase_val={2}>H. 2 chữ</button>
  <button class="-txt _md" data-kbd="3" use:upcase_val={3}>H. 3 chữ</button>
  <button class="-txt" data-kbd="4" use:upcase_val={9}>H. tất cả</button>
  <button class="-txt" data-kbd="0" use:upcase_val={0}>Không hoa</button>

  <div class="right">
    <button
      class="-btn"
      data-kbd="r"
      disabled={_orig == value || !_orig}
      on:click={() => (value = _orig)}>
      <SIcon name="corner-up-left" />
    </button>

    <button class="-btn" data-kbd="e" on:click={() => (value = '')}>
      <SIcon name="erase" />
    </button>
  </div>
</div>

<style lang="scss">
  $height: 2.25rem;

  .vutil {
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    padding: 0 0.375rem;
    font-size: rem(11px);

    @include flex();
    @include border($sides: top);
  }

  .-txt {
    float: left;
    padding: 0 0.375rem;
    line-height: $height;
    font-weight: 500;
    text-transform: uppercase;
    background: none;
    @include fgcolor(neutral, 5);

    // max-width: 14vw;
    @include truncate(null);

    &:hover {
      @include fgcolor(primary, 5);
    }

    &._md {
      @include props(display, none, $md: inline-block);
    }
  }

  .right {
    margin-left: auto;
    display: flex;
  }

  .-btn {
    padding: 0;
    width: 1.75rem;
    padding-bottom: 0.25rem;

    background: none;

    font-size: rem(18px);
    @include fgcolor(neutral, 5);

    &:hover {
      @include fgcolor(primary, 5);
    }

    &[disabled] {
      @include fgcolor(neutral, 3);
    }
  }
</style>
