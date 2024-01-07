<script lang="ts">
  import Cztext from '$gui/shared/upload/Cztext.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let ztext = data.ztext

  let vhtml: string = ''
  let error: string = ''
</script>

<div class="content">
  <Cztext bind:ztext bind:error limit={1000} />

  <section class="output">
    {#if error}
      <div class="form-msg _err">{error}</div>
    {:else if ztext}
      <p>Đang viết lại, mời quay lại sau!</p>
    {:else}
      <p>Nhập văn bản vào phía bên trái</p>
    {/if}
  </section>
</div>

<style lang="scss">
  .content {
    display: flex;
    margin-top: 1rem;

    > :global(*) {
      flex: 1 1;
      width: 50%;
    }

    > :global(.ztext) {
      @include bdradi(0, $loc: right);
    }
  }

  .output {
    @include border(--bd-main);
    border-left: none;
    @include bdradi($loc: right);
    // padding-left: 0.75rem;
    // padding: 0 0.75rem;
  }
</style>
