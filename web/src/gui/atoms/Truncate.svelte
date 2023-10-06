<script lang="ts">
  import { onMount } from 'svelte'
  import SIcon from './SIcon.svelte'

  export let html: string
  export let view_all = false
  export let show_btn = false

  onMount(() => {
    show_btn ||= elem.scrollHeight > elem.clientHeight
  })

  let elem: HTMLElement
  $: truncate = (elem && elem.scrollHeight > elem.clientHeight) || false
</script>

<div class="wrap">
  <div
    class="text"
    class:_full={view_all}
    class:_trim={truncate}
    bind:this={elem}>
    {@html html}
  </div>
  {#if show_btn}
    <footer class="foot">
      <button
        type="button"
        class="m-btn _xs"
        on:click={() => (view_all = !view_all)}>
        {#if view_all}
          <SIcon name="chevron-up" />
          <span class="-txt">Thu hẹp</span>
        {:else}
          <SIcon name="chevron-down" />
          <span class="-txt">Mở rộng</span>
        {/if}
      </button>
    </footer>
  {/if}
</div>

<style lang="scss">
  .wrap {
    position: relative;
  }

  .text {
    :global(*) {
      margin-top: 1em;
    }
  }

  .text:not(._full) {
    display: -webkit-box;

    -webkit-line-clamp: var(--line, 6);
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: '…';
  }

  .text._full {
    padding-bottom: 0.5em;
  }

  ._trim {
    // margin-bottom: 0.5rem;
    --bg-hide: #{color(neutral, 7, 1)};
    background: linear-gradient(
      to top,
      color(--bg-hide) 0.125rem,
      transparent 0.5rem
    );

    @include tm-dark {
      --bg-hide: #{color(neutral, 5, 1)};
    }
  }

  .foot {
    @include flex-ca;
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    width: 100%;
    transform: translateY(50%);
  }

  .m-btn {
    width: 6rem;
  }
</style>
