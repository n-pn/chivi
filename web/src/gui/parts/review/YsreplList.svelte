<script lang="ts">
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import YsreplCard from '$gui/parts/review/YsreplCard.svelte'

  export let replies: CV.YsreplPage
  export let _active = true
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
<div class="wrap" data-kbd="esc" on:click={() => (_active = false)} role="dialog">
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div class="main island" on:click={(e) => e.stopPropagation()}>
    <header class="head">
      <div class="title">Phản hồi bình luận</div>
      <button on:click={() => (_active = false)}><SIcon name="x" /></button>
    </header>

    <section class="body">
      <div class="repls">
        {#each replies.repls as yrepl}
          <YsreplCard {yrepl} />
        {:else}
          <div class="d-empty-sm">Không có phản hồi.</div>
        {/each}
      </div>
    </section>
  </div>
</div>

<style lang="scss">
  .wrap {
    @include flex($center: both);
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    z-index: 9999;
    background: rgba(#000, 0.75);
  }

  .main {
    $max-width: 40rem;

    width: $max-width;
    min-width: 320px;
    max-width: 100%;

    @include bgcolor(tert);
    @include shadow(3);

    @include bp-min($max-width) {
      @include bdradi();
    }
  }

  .head {
    position: relative;
    text-align: center;
    padding: 0.25rem;
    line-height: 2rem;
    font-weight: 500;
    // @include ftsize(lg);

    button {
      position: absolute;
      right: 0.5rem;
      // top: 0.25rem;
      top: 0;
      background: transparent;
      padding: 0.25rem;
      @include fgcolor(tert);
      --linesd: none !important;
    }
  }

  .body {
    // @include bgcolor(secd);
    padding: 0 var(--gutter);

    margin-top: 0.25rem;
    margin-bottom: 0.25rem;
    overflow: auto;
    max-height: calc(100vh - 6rem);
    scrollbar-width: thin;
    &::-webkit-scrollbar {
      cursor: pointer;
      width: 8px;
    }
  }
</style>
