<script>
  import { scale, fade } from 'svelte/transition'
  import { backInOut } from 'svelte/easing'
  import { layers } from '$lib/stores'

  export let actived = true
  export let zindex = 70
  export let _klass = 'gmodal'
  export let on_close = () => {}

  $: layers.toggle(actived, '.' + _klass)

  function close_modal() {
    actived = false
    on_close()
  }
</script>

<modal-wrap
  class={_klass}
  on:click={close_modal}
  transition:fade={{ duration: 100 }}
  style="--index: {zindex}">
  <modal-body
    on:click={(e) => e.stopPropagation()}
    transition:scale={{ duration: 100, easing: backInOut }}>
    <slot />
  </modal-body>
</modal-wrap>

<style lang="scss">
  modal-wrap {
    @include flex-ca;
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    z-index: var(--index, 60);
    background: rgba(#000, 0.75);
  }

  modal-body {
    max-width: 100%;
  }
</style>
