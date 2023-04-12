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
  <table>
    <thead>
      <tr>
        <th>#</th>
        <th>Người gửi</th>
        <th>Người nhận</th>
        <th>Số vcoin</th>
        <th>Lý do gửi</th>
        <th>Thời gian</th>
      </tr>
    </thead>

    <tbody>
      {#each data.xlogs as xlog}
        {@const sender = data.users[xlog.sender_id]}
        {@const receiver = data.users[xlog.receiver_id]}
        <tr>
          <td>{xlog.id}</td>
          <td>
            <span class="cv-user" data-privi={sender.privi}>
              <SIcon name="privi-{sender.privi}" iset="sprite" />
              {sender.uname}
            </span>
          </td>
          <td>
            <span class="cv-user" data-privi={receiver.privi}>
              {receiver.uname}
              <SIcon name="privi-{receiver.privi}" iset="sprite" />
            </span>
          </td>
          <td>{xlog.amount}</td>
          <td>{xlog.reason}</td>
          <td>{rel_time(xlog.ctime)}</td>
        </tr>
      {/each}
    </tbody>
  </table>
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
</style>
