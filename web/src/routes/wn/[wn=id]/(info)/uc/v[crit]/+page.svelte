<script lang="ts">
  // import SIcon from '$gui/atoms/SIcon.svelte'
  import VicritCard from '$gui/parts/review/VicritCard.svelte'
  import RpnodeList from '$gui/parts/dboard/RpnodeList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: gdroot = `vc:${data.crit.id}`
  $: touser = data.crit.user_id
</script>

<h3 id="vcrit">
  Đánh giá truyện của <strong>{data.user.uname}</strong> cho bộ truyện
  <strong>{data.book.vtitle}</strong>
</h3>

<VicritCard {...data} show_book={false} view_all={true} />

<section id="repls" class="repls">
  <h3 class="repls-head">
    Bình luận đánh giá <span class="m-badge">{data.rplist.repls.length}</span>
  </h3>

  <RpnodeList rplist={data.rplist} {gdroot} {touser} fluid={true} />
</section>

<style lang="scss">
  .repls-head {
    margin-bottom: 0.75rem;
  }

  .repls {
    @include bp-min(tl) {
      @include padding-x(var(--gutter));
    }
  }
</style>
