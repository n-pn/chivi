<script lang="ts">
  import { session } from '$lib/stores'

  import { SIcon } from '$gui'
  import BookTrack from '$gui/parts/BookTrack.svelte'

  export let nvinfo: CV.Nvinfo
</script>

<div class="user-action">
  <div class="book-track">
    <BookTrack />
  </div>

  <a class="m-btn" href="/dicts/-{nvinfo.bhash}" data-kbd="p">
    <SIcon name="package" />
  </a>

  {#if $session.privi > 0}
    <a class="m-btn _harmful" href="/-{nvinfo.bslug}/+info">
      <SIcon name="edit" />
    </a>
  {/if}
</div>

<style lang="scss">
  .user-action {
    grid-area: d;
    display: flex;
    gap: 0.5rem;
    align-items: center;
    // margin-top: 0.5rem;

    // @include padding-x(var(--gutter));
    justify-content: center;

    @include bp-min(pl) {
      justify-content: left;
    }
  }
</style>
