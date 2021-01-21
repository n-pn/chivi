<script>
  import { titleize } from '$utils/text_utils'

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
  <button data-kbd="1" use:upcase_val={1}>
    <span class="_md">hoa</span>
    một chữ
  </button>
  <button data-kbd="2" use:upcase_val={2}>hai chữ</button>
  <button class="_md" data-kbd="3" use:upcase_val={3}>ba chữ</button>
  <button data-kbd="4" use:upcase_val={99}>tất cả</button>
  <button data-kbd="0" use:upcase_val={0}>
    không
    <span class="_sm">hoa</span>
  </button>
  <button class="_right" data-kbd="e" on:click={() => (value = '')}>Xoá</button>
  {#if value != _orig}
    <button class="_right" data-kbd="r" on:click={() => (value = _orig)}
      >Phục</button>
  {/if}
</div>

<style lang="scss">
  $height: 2.25rem;

  .vutil {
    padding: 0 0.375rem;
    overflow: hidden;
    height: $height;

    z-index: 0;
    @include flow();
    @include props(font-size, rem(11px), $md: rem(12px));
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

    &._right {
      float: right;
    }
  }

  ._md {
    display: none;
    @include screen-min(md) {
      display: inline-block;
    }
  }

  ._sm {
    display: none;
    @include screen-min(sm) {
      display: inline-block;
    }
  }
</style>
