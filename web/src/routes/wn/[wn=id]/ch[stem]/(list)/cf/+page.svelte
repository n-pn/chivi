<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import RemoteLink from './RemoteLink.svelte'
  import CutChapters from './CutChapters.svelte'
  // import CopyChapters from './CopyChapters.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo, wstem } = data)

  $: edit_url = `/_wn/seeds/${nvinfo.id}/${wstem.sname}`
  $: ztitle = `${nvinfo.ztitle} ${nvinfo.zauthor}`

  $: can_conf = $_user.privi > 2
</script>

<h2>Cài đặt nguồn truyện</h2>

<details open>
  <summary>Liên kết đồng bộ với các nguồn ngoài</summary>
  <RemoteLink {ztitle} {can_conf} {edit_url} bind:wstem={data.wstem} />
</details>

<!-- <details>
    <summary>Sao chép từ danh sách chương tiết khác</summary>
    <CopyChapters
      book_info={nvinfo}
      seed_list={data.seed_list}
      {wstem}
      {can_edit}
      {edit_url} />
  </details> -->

<details>
  <summary>Cắt bỏ các chương tiết bị thừa</summary>
  <CutChapters book_info={nvinfo} {wstem} {can_conf} {edit_url} />
</details>

<style lang="scss">
  h2 {
    margin-bottom: 1rem;
  }

  details {
    @include border(--bd-soft, $loc: top);
    padding-top: 0.5rem;
    margin-bottom: 0.75rem;
  }

  summary {
    font-weight: 500;
    font-size: rem(17px);
    // @include ftsize(lg);
    @include fgcolor(secd);

    &:hover,
    details[open] & {
      @include fgcolor(primary, 5);
    }
  }
</style>
