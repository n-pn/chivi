<script lang="ts">
  // import { page } from '$app/stores'
  import { goto } from '$app/navigation'

  import { api_call } from '$lib/api_call'
  import { SIcon } from '$gui'

  import ReadPrivi from './ReadPrivi.svelte'
  import Remotes from './Remotes.svelte'
  import DeleteSeed from './DeleteSeed.svelte'
  import CutChapters from './CutChapters.svelte'
  import CopyChapters from './CopyChapters.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo, curr_seed } = data)

  $: can_edit = check_privi(data.curr_seed, data.seed_data, data._user)

  $: edit_url = `/_wn/seeds/${nvinfo.id}/${curr_seed.sname}`
  $: ztitle = `${nvinfo.btitle_zh} ${nvinfo.author_zh}`

  const check_privi = ({ sname }, { edit_privi }, { uname, privi }) => {
    if (privi < edit_privi) return false
    if (privi > 3 || sname[0] != '@') return true
    return sname == '@' + uname
  }
</script>

<article class="article island">
  <h2>Cài đặt nguồn truyện</h2>

  <details open>
    <summary>Quyền hạn tối thiểu để xem nội dung chương tiết</summary>
    <ReadPrivi
      {can_edit}
      {edit_url}
      seed_data={data.seed_data}
      bind:curr_seed={data.curr_seed} />
  </details>

  <details>
    <summary>Liên kết đồng bộ với các nguồn ngoài</summary>
    <Remotes {ztitle} {can_edit} {edit_url} bind:seed_data={data.seed_data} />
  </details>

  <details>
    <summary>Sao chép từ danh sách chương tiết khác</summary>
    <CopyChapters
      book_info={nvinfo}
      seed_list={data.seed_list}
      {curr_seed}
      {can_edit}
      {edit_url} />
  </details>

  <details>
    <summary>Cắt bỏ các chương tiết bị thừa</summary>
    <CutChapters book_info={nvinfo} {curr_seed} {can_edit} {edit_url} />
  </details>

  <details>
    <summary>Xoá danh sách chương tiết</summary>
    <DeleteSeed {curr_seed} {edit_url} {can_edit} bslug={nvinfo.bslug} />
  </details>
</article>

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
