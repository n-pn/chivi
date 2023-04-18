<script lang="ts">
  import type { Writable } from 'svelte/store'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import UpgradePrivi from './Setting/UpgradePrivi.svelte'
  import SendVcoin from './Setting/SendVcoin.svelte'
  import UpdatePasswd from './Setting/UpdatePasswd.svelte'

  export let _user: Writable<App.CurrentUser>

  async function logout() {
    const res = await fetch('/_db/_user/logout', { method: 'DELETE' })
    if (res.ok) {
      $_user = (await res.json()) as App.CurrentUser
    }
  }
</script>

<details open>
  <summary>Nâng quyền hạn</summary>
  <UpgradePrivi {_user} />
</details>

<details>
  <summary>Tặng vcoin</summary>
  <SendVcoin {_user} />
</details>

<details>
  <summary>Đổi mật khẩu</summary>
  <UpdatePasswd {_user} />
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
