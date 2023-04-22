<script lang="ts">
  import WncritList from '$gui/parts/review/WncritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  import SIcon from '$gui/atoms/SIcon.svelte'
</script>

<WncritList
  ys={data.ys || undefined}
  vi={data.vi || undefined}
  _sort={data.sort || 'score'}
  show_book={false}>
  <a
    class="m-btn _primary _fill _lg"
    href="/uc/+crit?wn={data.nvinfo.id}"
    slot="add_crit">
    <SIcon name="ballpen" />
    <span class="-text">Thêm đánh giá</span>
  </a>
</WncritList>
