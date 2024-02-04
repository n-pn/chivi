<script lang="ts" context="module">
  const from_types = { '': 'Xem tất cả', 'users': 'Từ người dùng', 'ysapp': 'Ưu Thư Võng' }
  const sort_types = { score: 'Nổi bật', utime: 'Gần nhất' }
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { Pager } from '$gui/molds/Mpager.svelte'

  export let qdata = {
    in: '',
    by: '',
    gt: 1,
    lt: 5,
    pg: 1,
    _s: 'score',
  }

  export let pager = new Pager($page.url, qdata)
</script>

<nav class="m-flex _cx">
  <span class="m-chips">
    {#each Object.entries(from_types) as [type, label]}
      <a href={pager.gen_url({ in: type })} class="m-tag _lg" class:_active={type == qdata.in}
        >{label}</a>
    {/each}
  </span>
</nav>

<div class="qdata">
  <div class="stars m-flex _cx">
    <span class="label">Số sao:</span>

    {#each [1, 2, 3, 4, 5] as star}
      {@const _active = star >= qdata.gt && star <= qdata.lt}
      {@const gt = _active || star < qdata.gt ? star : qdata.gt}
      {@const st = _active || star > qdata.lt ? star : qdata.lt}
      {@const href = pager.gen_url({ ...qdata, gt, st, pg: 1 })}

      <a {href} class="m-star" class:_active>
        <span>{star}</span>
        <SIcon name="star" iset="icons" />
      </a>
    {/each}
  </div>

  <div class="filter u-right">
    {#each Object.entries(sort_types) as [_s, name]}
      {@const href = pager.gen_url({ _s, pg: 1 })}
      <a {href} class="-child" class:_active={_s == qdata._s}>
        <span>{name}</span>
      </a>
    {/each}
  </div>
</div>
