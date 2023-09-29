<script lang="ts">
  import SIcon from './SIcon.svelte'

  export let html: string

  export let show_btn = true
  export let view_all = false

  let elem: HTMLElement
  $: clamped = (elem && elem.scrollHeight > elem.clientHeight) || false
</script>

<div class="wrap">
  <div
    class="text"
    class:_full={view_all}
    class:_trim={clamped}
    bind:this={elem}>
    {@html html}
  </div>
  {#if show_btn}
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
  {/if}
</div>

<style lang="scss">
  .wrap {
    position: relative;
    margin-bottom: 0.5rem;

    :global(* + *) {
      margin-top: 1em;
    }
  }

  .text {
    padding-bottom: 1rem;
  }

  .text:not(._full) {
    display: -webkit-box;
    -webkit-line-clamp: var(--line, 10);
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: '…';
  }

  ._trim {
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

  .m-btn {
    position: absolute;
    bottom: 0;
    left: 0;
    margin-left: 50%;
    transform: translateX(-50%) translateY(50%);
    width: 6rem;
  }
</style>
