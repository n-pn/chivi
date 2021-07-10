<script context="module">
  export async function load({ fetch, page: { params, query } }) {
    const slug = params.dict
    const page = +query.get('page') || 1

    const url = `/api/dicts/${slug}?page=${page}`
    const res = await fetch(url)

    const data = await res.json()
    return { props: { ...data, page } }
  }

  import { labels } from '$lib/postag'
</script>

<script>
  import Vessel from '$lib/layouts/Vessel.svelte'
  import SIcon from '$lib/blocks/SIcon.svelte'
  import { get_rtime_short } from '$lib/blocks/RTime.svelte'

  export let label = 'Thông dụng'
  export let dname = 'regular'
  export let p_min = 1
  export let terms = []

  export let page = 1
  $: offset = (page - 1) * 50 + 1

  function render_time(mtime) {
    return mtime > 1577836800 ? get_rtime_short(mtime) : '-'
  }

  function render_ptag(tag) {
    return labels[tag] || tag || '-'
  }

  function render_rank(wgt) {
    switch (wgt) {
      case 1:
        return '-2'
      case 2:
        return '-1'
      case 4:
        return '+1'
      case 5:
        return '+2'
      default:
        return '-'
    }
  }

  // function render_privi(privi) {
  //   if (p_min == privi) return '-'
  //   if (p_min > privi) return '-' + (p_min - privi)
  //   return '+' + (privi - p_min)
  // }
</script>

<Vessel>
  <article class="m-article">
    <h1>Từ điển: {label}</h1>

    <div class="table">
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>Trung</th>
            <th>Nghĩa Việt</th>
            <th>Phân loại</th>
            <th>Ư.t</th>
            <th>Người dùng</th>
            <th>Q.h</th>
            <th>Cập nhật</th>
          </tr>
        </thead>

        <tbody>
          {#each terms as { key, val, tag, wgt, mtime, uname, privi }, idx}
            <tr>
              <td class="-idx">{offset + idx}</td>
              <td class="-key">{key}</td>
              <td class="-val">{val.join(' / ')}</td>
              <td class="-tag">{render_ptag(tag)}</td>
              <td class="-wgt">{render_rank(wgt)}</td>
              <td class="-uname">{uname == '_' ? '-' : uname}</td>
              <td class="-privi" class:_gt={privi > p_min}>{privi}</td>
              <td class="-mtime">{render_time(mtime)}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>

    <footer class="pagi">
      {#if page > 1}
        <a class="m-button" href="/dicts/{dname}?page={page - 1}"
          ><SIcon name="chevron-left" />
          <span class="-txt">Trước</span>
        </a>
      {:else}
        <div class="m-button _disable">
          <SIcon name="chevron-left" />
          <span class="-txt">Trước</span>
        </div>
      {/if}

      {#if terms.length >= 30}
        <a class="m-button _primary" href="/dicts/{dname}?page={page + 1}">
          <span class="-txt">Kế tiếp</span>
          <SIcon name="chevron-right" />
        </a>
      {:else}
        <div class="m-button _disable">
          <span class="-txt">Kế tiếp</span>
          <SIcon name="chevron-right" />
        </div>
      {/if}
    </footer>
  </article>
</Vessel>

<style lang="scss">
  article {
    margin: 1rem 0;
    padding: 1rem;
    background: #fff;
    @include shadow();
    @include radius();
    @include fgcolor(neutral, 8);
  }

  .pagi {
    display: flex;
    justify-content: center;

    .m-button + .m-button {
      // width: 5rem;
      // text-align: center;
      margin-left: 0.5rem;
    }
  }

  .table {
    display: block;
    width: 100%;
    overflow-x: auto;
    white-space: nowrap;
  }

  table {
    width: 100%;
    max-width: 100%;
  }

  th,
  td {
    text-align: center;
    line-height: 1.5rem;
    padding: 0.375rem 0.5rem;
  }

  tbody > tr:hover {
    cursor: pointer;
    background-color: color(primary, 4, 0.1);
  }

  .-idx,
  .-wgt,
  .-tag,
  .-mtime,
  .-privi,
  .-uname {
    font-size: rem(14px);
    @include truncate(null);
    @include fgcolor(neutral, 6);
  }

  .-privi._gt {
    @include fgcolor(primary, 6);
  }

  .-val {
    font-size: rem(14px);
    @include truncate(null);
  }
</style>
