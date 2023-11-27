<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'
  import UpdatePasswd from '$gui/shared/usercp/Setting/UpdatePasswd.svelte'

  async function logout() {
    const res = await fetch('/_db/_user/logout', { method: 'DELETE' })
    if (!res.ok) return
    window.location.reload()
  }
</script>

<article class="article island">
  <h1>Thông tin cá nhân</h1>

  <details open>
    <summary>Đổi mật khẩu</summary>
    <UpdatePasswd {_user} />
  </details>

  <div class="form-action">
    <button class="m-btn btn-back" on:click={logout}>
      <SIcon name="logout" />
      <span>Đăng xuất</span>
    </button>
  </div>
</article>

<style lang="scss">
  h1 {
    margin-bottom: 1rem;
    text-align: center;
  }
  details {
    padding-top: 0.75rem;
    padding-bottom: 0.75rem;
    margin-bottom: 0.75rem;
    max-width: 30rem;
    margin: 0 auto;

    @include border($loc: top-bottom);
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
