<script lang="ts">
  import type { Writable } from 'svelte/store'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import UpgradePrivi from './Setting/UpgradePrivi.svelte'
  import AddDonation from './Setting/AddDonation.svelte'
  import SendVcoin from './Setting/SendVcoin.svelte'

  export let _user: Writable<App.CurrentUser>

  $: xlog_url = $_user.privi > 3 ? '/su/xvcoin' : '/me/xvcoin'
</script>

{#if $_user.privi > 3}
  <details open>
    <summary>Ghi nhận ủng hộ</summary>
    <AddDonation {_user} />
  </details>
{:else}
  <details open>
    <summary>Nâng cấp quyền hạn</summary>
    <UpgradePrivi {_user} />
  </details>
{/if}

<details>
  <summary>Trao tặng vcoin</summary>
  <SendVcoin {_user} />
</details>

<div class="form-action">
  <a class="m-btn _primary" href={xlog_url}>
    <SIcon name="article" />
    <span class="-txt">Lịch sử giao dịch</span>
  </a>
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
