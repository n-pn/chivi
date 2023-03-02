<script lang="ts">
  import { rel_time } from '$utils/time_utils'
  import type { PageData } from './$types'
  export let data: PageData
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
        {@const sender = data.users[xlog.sender]}
        {@const sendee = data.users[xlog.sendee]}
        <tr>
          <td>{xlog.id}</td>
          <td><cv-user data-privi={sender.privi}>{sender.uname}</cv-user></td>
          <td><cv-user data-privi={sendee.privi}>{sendee.uname}</cv-user></td>
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
