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
        <th class="id">#</th>
        <th>Bộ truyện</th>
        <th>Điểm giá trị</th>
        <th>Lựa chọn</th>
        <th>Thời gian</th>
      </tr>
    </thead>

    <tbody>
      {#each data.xlogs as xlog, index}
        {@const id = index + 1 + (data.pgidx - 1) * 20}
        {@const book = data.books[xlog.wn_dic]}
        <tr>
          <td class="id">{id}</td>
          <td class="title">
            <a class="link" href="/wn/{book.bslug}">{book.vtitle}</a>
          </td>
          <td>
            <div class="value">
              <span class="fg-secd" data-tip="Số lượng chữ gốc của chương"
                >{xlog.char_count}</span>
              <span class="fg-mute"><SIcon name="arrow-right" /></span>
              <a
                class="link"
                href={pager.gen_url({ ihash: xlog.input_hash, pg: 1 })}
                data-tip="Điểm giá trị sau khi nhân chia theo hệ số">
                {xlog.point_cost}
              </a>
            </div>
          </td>
          <td class="flags">
            {#if xlog.w_udic}
              <span class="check" data-tip="Dùng từ điển cá nhân"
                ><SIcon name="check" />Từ điển riêng</span>
            {/if}
            {#if xlog.cv_ner}
              <span
                class="check"
                data-tip="Dùng công cụ nhận dạng thực thể của Chivi"
                ><SIcon name="check" />Nhận thực thể</span>
            {/if}
            {#if xlog.ts_sdk}
              <span
                class="check"
                data-tip="Dùng công cụ nhận dạng thực thể offline của Texsmart"
                >Texsmart SDK<SIcon name="check" /></span>
            {/if}
            {#if xlog.ts_acc}
              <span
                class="check"
                data-tip="Dùng công cụ nhận dạng thực thể online của Texsmart"
                >Texsmart API<SIcon name="check" /></span>
            {/if}
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

  table {
    margin-top: 1rem;
  }

  th,
  td {
    border-left: none;
    border-right: none;
    text-align: center;
  }

  td {
    @include ftsize(sm);
  }

  footer {
    margin-top: 0.75rem;
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

  .ctime {
    @include clamp($width: null);
    @include fgcolor(tert);
  }

  .check {
    display: inline-flex;
    align-items: center;
    gap: 0.125rem;
    @include ftsize(xs);
    @include fgcolor(success, 5);
    // text-transform: uppercase;
  }

  .id {
    @include ftsize(sm);
    @include fgcolor(tert);
    padding: 0;
  }
</style>
