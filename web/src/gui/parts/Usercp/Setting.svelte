<script lang="ts">
  import { SIcon } from '$gui'

  import UpgradePrivi from './Setting/UpgradePrivi.svelte'
  import SendVcoin from './Setting/SendVcoin.svelte'
  import UpdatePasswd from './Setting/UpdatePasswd.svelte'

  export let tab = 2

  async function logout() {
    await fetch('/api/_user/logout', { method: 'DELETE' })
    window.location.reload()
  }
</script>

<details open>
  <summary>Nâng quyền hạn</summary>
  <UpgradePrivi bind:tab />
</details>

<details>
  <summary>Tặng vcoin</summary>
  <SendVcoin />
</details>

<details>
  <summary>Đổi mật khẩu</summary>
  <UpdatePasswd bind:tab />
</details>

<div class="form-action">
  <button class="m-btn btn-back" on:click={logout}>
    <SIcon name="logout" />
    <span>Đăng xuất</span>
  </button>
</div>

<style lang="scss">
  details {
    padding-bottom: 0.75rem;
    margin-bottom: 0.75rem;
    @include border($loc: bottom);
  }

  summary {
    margin: 0;
    font-weight: 500;
    @include ftsize(lg);
    // @include fgcolor(secd);
  }

  summary:marker {
    display: none;
  }
</style>
