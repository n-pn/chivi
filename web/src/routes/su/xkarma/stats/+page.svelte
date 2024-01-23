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
  <h1>Lịch sử dịch chương</h1>

  <table>
    <thead>
      <tr>
        <th class="id">#ID</th>
        <th>Người dùng</th>
        <th>Bộ truyện</th>
        <th>Điểm giá trị</th>
        <th>Lựa chọn</th>
        <th>Thời gian</th>
      </tr>
    </thead>

    <tbody>
      {#each data.xlogs as xlog}
        {@const user = data.users[xlog.viuser_id]}
        {@const book = data.books[xlog.wn_dic]}
        <tr>
          <td class="id">{xlog.id}</td>
          <td>
            <a
              class="cv-user"
              href={pager.gen_url({ vu_id: xlog.viuser_id, pg: 1 })}
              data-privi={user.privi}>
              <SIcon name="privi-{user.privi}" iset="icons" />
              {user.uname}
            </a>
          </td>
          <td class="title">
            <a class="link" href="/wn/{book.id}">{book.vtitle}</a>
          </td>
          <td>
            <div class="value">
              <span class="u-fg-secd" data-tip="Số lượng chữ gốc của chương"
                >{xlog.char_count}</span>
              <span class="u-fg-mute"><SIcon name="arrow-right" /></span>
              <a
                class="link"
                href={pager.gen_url({ ihash: xlog.input_hash, pg: 1 })}
                data-tip="Điểm giá trị sau khi nhân chia theo hệ số">
                {xlog.point_cost}
              </a>
            </div>
          </td>

          <td class="ctime"
            >{rel_time(new Date(xlog.created_at).getTime() / 1000)}</td>
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
  }

  table,
  footer {
    margin-top: 0.75rem;
  }

  th,
  td {
    border-left: none;
    border-right: none;
    text-align: center;
    padding: 0.25rem 0.5rem;
  }

  td {
    @include ftsize(sm);
  }

  .cv-user {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
  }

  .title {
    max-width: 10rem;
    a {
      @include clamp($width: null);
      display: block;
    }
  }

  .link {
    @include fgcolor(primary, 5);
  }

  .id {
    @include ftsize(sm);
    @include fgcolor(tert);
    padding: 0;
  }

  .ctime {
    @include clamp($width: null);
    @include fgcolor(tert);
  }

  // .check {
  //   display: inline-flex;
  //   align-items: center;
  //   gap: 0.125rem;
  //   @include ftsize(xs);
  //   @include fgcolor(success, 5);
  //   // text-transform: uppercase;
  // }

  .value {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.25rem;
  }
</style>
