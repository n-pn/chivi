<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import Notext from './errors/Notext.svelte'
  import Unlock from './errors/Unlock.svelte'

  export let crepo: CV.Tsrepo
  export let rdata: CV.Chinfo
  export let state = 0
</script>

<section class="reader">
  {#if $_user.uname == 'Khách'}
    <h1 class="u-warn">Lỗi: Chưa đủ quyền hạn xem chương</h1>
    <p>
      <em
        >Bạn chưa đăng nhập. Nếu bạn đã có tài khoản, đăng nhập tại đây: <a href="/_u/login"
          >Đăng nhập</a>
        . Nếu chưa có tài khoản, hãy đăng ký mới tại đây:
        <a href="/_u/signup">Đăng ký tài khoản mới</a>
      </em>
    </p>
  {:else if rdata.error == 403}
    <div class="d-empty">
      <h1 class="u-warn">
        Lỗi: Bạn cần thiết quyền hạn tối thiểu là {rdata.plock} để xem nội dung chương!
      </h1>
      <p>
        Đọc thêm về hướng dẫn nâng cấp tài khoản <a href="/hd/nang-cap-quyen-han">tại đây.</a>
      </p>
    </div>
  {:else if rdata.error == 414}
    <Notext {crepo} bind:rdata bind:state />
  {:else if rdata.error == 413 || rdata.error == 415}
    <Unlock {crepo} bind:rdata bind:state />
  {:else}
    <h1>{rdata.error}</h1>
  {/if}
</section>

<style lang="scss">
  section {
    margin: 0 auto;
    max-width: 45rem;
  }
</style>
