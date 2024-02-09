<script lang="ts">
  import type { PageData } from './$types'
  export let data: PageData

  $: ({ rolls, avail } = data)

  let _msg = `Bạn còn ${data.avail} lượt nhận lì xì!`
  let _stt = ''

  async function roll() {
    _stt = ''
    const url = '/_db/li-xi/roll'
    const res = await fetch(url, { method: 'PUT' })

    if (!res.ok) {
      _msg = await res.text()
      _stt = 'err'
    } else {
      const rdata = await res.json()
      _stt = 'ok'
      _msg = `Chúc mừng, bạn đã nhận được ${rdata.vcoin} vcoin!`
      rolls = rdata.rolls
      avail = rdata.avail
    }
  }

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { rel_time } from '$utils/time_utils'
</script>

<article class="article island md-post">
  <h1>Chúc mừng năm mới 2024!</h1>
  <p class="u-warn">
    <em
      >Bấm nút bên dưới để nhận lì xì. Bạn sẽ nhận được ngẫu nhiên từ 1 tới 50 vcoin từ mỗi lượt
      bấm. Số lượt bấm của bạn được tính bằng quyền hạn của bạn + 1.</em>
  </p>

  <div class="roll">
    <button class="m-btn _xl _fill _harmful" on:click={roll} disabled={avail < 1}>
      <SIcon name="gift" />
      <span>Nhận lì xì</span>
    </button>
    <div class="message _{_stt}">{_msg}</div>
  </div>

  <h3>Danh sách nhận thưởng</h3>
  <table>
    <thead>
      <tr>
        <th><a href="/me/event/li-xi">#</a></th>
        <th>Người nhận</th>
        <th><a href="/me/event/li-xi?sort=-vcoin">Số vcoin</a></th>
        <th>Thời gian</th>
      </tr>
    </thead>

    <tbody>
      {#each rolls as { id, uname, vcoin, mtime }}
        <tr>
          <td>{id}</td>
          <td><a href="/me/event/li-xi?user={uname}">{uname}</a></td>
          <td>{vcoin}</td>
          <td>{rel_time(mtime)}</td>
        </tr>
      {/each}
    </tbody>
  </table>
</article>

<style lang="scss">
  p {
    margin-top: 0.5rem;
  }

  table {
    margin-top: 1.25rem;

    th,
    td {
      text-align: center;
    }
  }

  .message {
    text-align: center;
    margin-top: 0.5rem;
    font-style: italic;
    @include fgcolor(neutral, 5);

    &._ok {
      @include fgcolor(success, 5);
    }
    &._err {
      @include fgcolor(harmful, 5);
    }
  }

  .roll {
    text-align: center;
    margin-top: 3rem;
  }
</style>
