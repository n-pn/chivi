<script lang="ts">
  import type { Writable } from 'svelte/store'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import SendVcoin from './Setting/SendVcoin.svelte'

  export let _user: Writable<App.CurrentUser>
</script>

<details>
  <summary>Trao tặng vcoin</summary>
  <SendVcoin {_user} />
</details>

{#if $_user.privi > 3}
  <details open>
    <summary>Quản lý hệ thống</summary>
    <div class="links">
      <a class="m-btn _sm _primary" href="/su/xvcoin">
        <SIcon name="article" />
        <span class="-txt">Giao dịch</span>
      </a>

      <a class="m-btn _sm _success" href="/su/unlock">
        <SIcon name="lock-open" />
        <span class="-txt">Mở khóa</span>
      </a>
    </div>
  </details>
{/if}

<details open>
  <summary>Lịch sử trao đổi</summary>
  <div class="links">
    <a class="m-btn _sm _primary" href="/me/xvcoin">
      <SIcon name="article" />
      <span class="-txt">Giao dịch</span>
    </a>

    <a class="m-btn _sm _success" href="/me/unlock">
      <SIcon name="lock-open" />
      <span class="-txt">Mở khóa</span>
    </a>

    <a class="m-btn _sm _warning" href="/me/earned">
      <SIcon name="coin" />
      <span class="-txt">Thu phí</span>
    </a>
  </div>
</details>

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

  .links {
    margin-top: 0.75rem;
    @include flex-ca($gap: 0.5rem);
    // flex-direction: column;
  }
</style>
