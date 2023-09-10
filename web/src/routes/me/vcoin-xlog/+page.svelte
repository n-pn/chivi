<script lang="ts">
  import { page } from '$app/stores'
  import { rel_time } from '$utils/time_utils'

  import type { PageData } from './$types'
  export let data: PageData

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  $: pager = new Pager($page.url, { pg: 1, tl: '' })
</script>

<article class="article island">
  <h1>Lịch sử giao dịch Vcoin</h1>

  <table class="table">
    <thead>
      <tr>
        <th>Người gửi</th>
        <th>Người nhận</th>
        <th>Số vcoin</th>
        <th>Lý do</th>
        <th>Thời gian</th>
      </tr>
    </thead>

    <tbody>
      {#each data.xlogs as xlog}
        {@const sender = data.users[xlog.sender_id]}
        {@const target = data.users[xlog.target_id]}
        <tr>
          <td>
            <span class="cv-user" data-privi={sender.privi}>
              <SIcon name="privi-{sender.privi}" iset="extra" />
              {sender.uname}
            </span>
          </td>
          <td>
            <span class="cv-user" data-privi={target.privi}>
              {target.uname}
              <SIcon name="privi-{target.privi}" iset="extra" />
            </span>
          </td>
          <td>{xlog.amount}</td>
          <td class="reason">{xlog.reason}</td>
          <td class="ctime">{rel_time(xlog.ctime)}</td>
        </tr>
      {/each}
    </tbody>
  </table>

  <footer>
    <Mpager {pager} pgidx={data.pgidx} pgmax={data.pgmax} />
  </footer>
</article>

<style lang="scss">
  article {
    margin-top: var(--gutter);

    th,
    td {
      border-left: none;
      border-right: none;
      text-align: center;
    }
  }

  table {
    margin-top: 1rem;
  }

  footer {
    margin-top: 0.75rem;
  }

  .cv-user {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
  }

  .reason {
    @include ftsize(sm);
    @include clamp($width: null);
    @include fgcolor(secd);
  }

  .ctime {
    @include ftsize(sm);
    @include clamp($width: null);
    @include fgcolor(tert);
  }
</style>
