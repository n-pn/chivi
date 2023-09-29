<script lang="ts">
  import { page } from '$app/stores'
  import { invalidate } from '$app/navigation'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { rel_time } from '$utils/time_utils'

  export let dlcvs: Array<any>
  export let pg_no = 1

  $: pager = new Pager($page.url, { pg: 1 })

  $: pgmax = dlcvs.length == 10 ? pg_no + 1 : pg_no

  const not_dead = (mtime: number) => {
    const now = new Date().getTime() / 1000
    return now - mtime < 600
  }

  let _onload = false
  async function retry(id: number) {
    _onload = true
    const res = await fetch(`/_db/dlcvs/${id}/retry`, { method: 'PATCH' })

    if (res.ok) {
      await invalidate('dlcvs')
    } else {
      alert(await res.text())
    }

    _onload = false
  }

  async function reload_all() {
    _onload = true
    await invalidate('dlcvs')
    _onload = false
  }
</script>

<p>
  <em
    >Bấm <button class="m-btn _xs" on:click={reload_all}
      ><SIcon name="refresh" /></button> để cập nhật trạng thái</em>
</p>

<div class="dlcvs">
  <table>
    <thead>
      <tr>
        <th align="center">Id</th>
        <th align="center">Từ chương</th>
        <th align="center">Tới chương</th>
        <th align="center">Số ký tự</th>
        <th align="center">Thời gian</th>
        <th align="center">Trạng thái </th>
      </tr>
    </thead>

    <tbody>
      {#each dlcvs as { id, from_ch_no, upto_ch_no, real_word_count, mtime, _flag }}
        <tr>
          <td>{id}</td>
          <td>{from_ch_no}</td>
          <td>{upto_ch_no}</td>
          <td>{real_word_count}</td>
          <td>{rel_time(mtime)}</td>
          <td>
            {#if _flag == 2}
              <a
                class="m-btn _success _xs _fill"
                href="/_db/dlcvs/{id}"
                download="{id}.txt">
                <SIcon name="download" />
                <span>Tải xuống</span>
              </a>
            {:else if _flag == 0}
              <span class="m-btn _xs">Đang đợi</span>
            {:else if _flag == 1 && not_dead(mtime)}
              <span class="m-btn _primary _xs">Đang dịch</span>
            {:else}
              <button
                class="m-btn _harmful _xs _fill"
                on:click={() => retry(id)}>
                <SIcon name="rotate" />
                <span>Lỗi. Thử lại</span>
              </button>
            {/if}
          </td>
        </tr>
      {/each}
    </tbody>
  </table>

  <footer>
    <Mpager {pager} pgidx={pg_no} {pgmax} />
  </footer>
</div>

<style lang="scss">
  table {
    margin-top: 0.75rem;
  }

  th,
  td {
    border-left: none;
    border-right: none;
    border-color: var(--bd-soft);
    text-align: center;
  }

  footer {
    display: flex;
    justify-content: center;
    margin-top: 0.75rem;
  }
</style>
