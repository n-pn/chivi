<script>
  import { titleize } from '$utils/text_utils'

  export let value

  function upcase_val(node, count) {
    const handle_click = (_) => (value = titleize(value, count))
    node.addEventListener('click', handle_click)

    return {
      destroy: () => node.removeEventListener('click', handle_click),
    }
  }
</script>

<div class="vutil">
  <button data-kbd="4" use:upcase_val={9}>Hoa tất cả</button>
  <button data-kbd="3" class="_md" use:upcase_val={3}>H. 3 chữ</button>
  <button data-kbd="2" use:upcase_val={2}>H. 2 chữ</button>
  <button data-kbd="1" use:upcase_val={1}>H. 1 chữ</button>
  <button data-kbd="0" use:upcase_val={0}>Không hoa</button>
</div>

<style lang="scss">
  $height: 2.25rem;

  .vutil {
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    padding: 0 0.375rem;
    height: $height;
    font-size: rem(11px);

    @include flow();
    @include border($sides: top);
  }

  button {
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
  }

  ._md {
    display: none;
    @include screen-min(md) {
      display: inline-block;
    }
  }
</style>
