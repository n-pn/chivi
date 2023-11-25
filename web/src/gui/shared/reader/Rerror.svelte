<script lang="ts">
  import Notext from './errors/Notext.svelte'
  import Unlock from './errors/Unlock.svelte'

  export let crepo: CV.Chrepo
  export let rdata: CV.Chpart
  export let state = 0
</script>

{#if rdata.error == 403}
  <div class="d-empty">
    <h1 class="u-warn">
      Lỗi: Bạn cần thiết quyền hạn tối thiểu là {rdata.plock} để xem nội dung chương!
    </h1>
    <p>
      Đọc thêm về hướng dẫn nâng cấp tài khoản <a href="/hd/nang-cap-quyen-han"
        >tại đây.</a>
    </p>
  </div>
{:else if rdata.error == 414}
  <Notext {crepo} bind:rdata bind:state />
{:else if rdata.error == 413 || rdata.error == 415}
  <Unlock {crepo} bind:rdata bind:state />
{:else}
  <h1>{rdata.error}</h1>
{/if}
