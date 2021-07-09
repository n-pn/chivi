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
  import { get_rtime } from '$lib/blocks/RTime.svelte'

  export let label = 'Thông dụng'
  export let dname = 'regular'
  export let p_min = 1
  export let terms = []

  export let page = 1
  $: offset = (page - 1) * 50 + 1

  function render_time(mtime) {
    return mtime > 1577836800 ? get_rtime(mtime) : '-'
  }

  function render_ptag(tag) {
    return labels[tag] || tag || '-'
  }

  function render_rank(wgt) {
    switch (wgt) {
      case 1:
        return 'Rất thấp'
      case 2:
        return 'Hơi thấp'
      case 4:
        return 'Hơi cao'
      case 5:
        return 'Rất cao'
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

    <table>
      <thead>
        <tr>
          <th>#</th>
          <th>Trung</th>
          <th>Nghĩa</th>
          <th>Từ loại</th>
          <th>Ưu tiên</th>
          <th>Cập nhật</th>
          <th>Người dùng</th>
          <th>Q. hạn</th>
        </tr>
      </thead>

      <tbody>
        {#each terms as { key, val, tag, wgt, mtime, uname, privi }, idx}
          <tr>
            <td class="-idx">{offset + idx}</td>
            <td class="-key">{key}</td>
            <td class="-val">{val.join(' / ')}</td>
            <td><span class="tag">{render_ptag(tag)}</span></td>
            <td class="-wgt">{render_rank(wgt)}</td>
            <td class="-mtime">{render_time(mtime)}</td>
            <td class="-uname">{uname == '_' ? '-' : uname}</td>
            <td
              class="-privi"
              class:_gt={privi > p_min}
              class:_lt={privi < p_min}>{privi}</td>
          </tr>
        {/each}
      </tbody>
    </table>

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

  thead {
    position: sticky;
    top: 0;
  }

  th {
    text-align: center;
    // @include fgcolor(neutral, 6);
  }

  td {
    text-align: center;
    line-height: 1.5rem;
    padding: 0.375rem 0.5rem;
  }

  table {
    width: 100%;
  }

  .-idx,
  .-wgt,
  .-mtime,
  .-privi,
  .-uname {
    font-size: rem(14px);
    @include truncate(null);
    @include fgcolor(neutral, 6);
  }

  .-privi {
    &._lt {
      @include fgcolor(neutral, 7);
    }
    &._gt {
      @include fgcolor(primary, 6);
    }
  }

  .-val {
    font-size: rem(14px);
    @include truncate(null);
  }

  .tag {
    display: inline-block;
    white-space: nowrap;
    padding: 0 0.5rem;
    // overflow: hidden;
    // text-overflow: ellipsis;

    --bdcolor: #{color(neutral, 2)};
    box-shadow: 0 0 0 1px var(--bdcolor);

    @include fgcolor(neutral, 6);
    @include radius(0.75rem);
    @include props(font-size, rem(12px), rem(13px), rem(14px));
  }
</style>
